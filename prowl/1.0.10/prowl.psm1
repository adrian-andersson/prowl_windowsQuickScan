<#
Module Mixed by BarTender
	A Framework for making PowerShell Modules
	Version: 6.2.0
	Author: Adrian.Andersson
	Copyright: 2020 Domain Group

Module Details:
	Module: prowl
	Description: Like the autobot of the same name, prowl around the Windows System and report back on security implications
	Revision: 1.0.9.1
	Author: Adrian.Andersson
	Company:  

Check Manifest for more details
#>


function Get-prowlAntivirusProducts {
    [cmdletBinding()]
    param (
    
    )
    BEGIN
    {

        $enumCode = @'
[Flags()] enum ProductState 
            {
                Off         = 0x0000
                On          = 0x1000
                Snoozed     = 0x2000
                Expired     = 0x3000
            }
            
            [Flags()] enum SignatureStatus
            {
                UpToDate     = 0x00
                OutOfDate    = 0x10
            }
            
            [Flags()] enum ProductOwner
            {
                NonMs        = 0x000
                Windows      = 0x100
            }
            
            # define bit masks
            
            [Flags()] enum ProductFlags
            {
                SignatureStatus = 0x00F0
                ProductOwner    = 0x0F00
                ProductState    = 0xF000
            }
'@

        $enumSB = [scriptblock]::create($enumCode)
        if($PSVersionTable.PSVersion -gt [version]::new('5.0.0'))
        {
            . $enumSB
        }
        
    }
    PROCESS
    {
        try{
            $AntivirusProduct = Get-CimInstance -Namespace root/SecurityCenter2 -Classname AntiVirusProduct -ErrorAction Stop
        }catch{
            write-warning 'CIMInstance for NameSpace SecurityCenter2 and class AntiVirusProduct unavailable - Either means no AV or your windows ver is old and this class doesnt exist'
        }
        
        if($AntivirusProduct)
        {
            foreach($avProduct in $AntivirusProduct)
            {
                $exe = $avProduct.pathToSignedReportingExe | Split-Path -Leaf
                
                $cimFilter = "name='$exe'"
                $cimProc = get-cimINstance win32_process -filter $cimFilter
    
                [UInt32]$state = $avProduct.productState

                if($PSVersionTable.PSVersion -gt [version]::new('5.0.0'))
                {
                
                    [PSCustomObject]@{
                        ProductName = $avProduct.DisplayName
                        ProductState = [ProductState]($state -band [ProductFlags]::ProductState)
                        SignatureStatus = [SignatureStatus]($state -band [ProductFlags]::SignatureStatus)
                        Owner = [ProductOwner]($state -band [ProductFlags]::ProductOwner)
                        EXE = $exe
                        ProcessIds = $cimProc.processId -join ','
                    }
                }else{
                    [PSCustomObject]@{
                        ProductName = $avProduct.DisplayName
                        ProductState = ''#[ProductState]($state -band [ProductFlags]::ProductState)
                        SignatureStatus = ''#[SignatureStatus]($state -band [ProductFlags]::SignatureStatus)
                        Owner = ''#[ProductOwner]($state -band [ProductFlags]::ProductOwner)
                        EXE = $exe
                        ProcessIds = $cimProc.processId -join ','
                    }
                }
            }
        }
        
    }
}


<#
$registeredAV = Get-AntivirusName


$cimFilter = "name='" + ($array -join "' or name='") +"'"
$cimProc = get-cimINstance win32_process -filter "Name "
#>

function get-prowlAwsMetaData
{

    <#
        .SYNOPSIS
            Get all the AWS MetaData if the URI exists
            
        .DESCRIPTION
            Get all the AWS MetaData if the URI exists
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Init Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $awsMetaUriBase = 'http://169.254.169.254/latest/meta-data/'
    }
    
    process{
        try{
            $rm = Invoke-RestMethod -Uri $awsMetaUriBase
        }catch{
            write-warning "$($_.Exception.Message)"
            return
        }

        if($rm)
        {
            $awsMetaHash = @{}
            $awsMetaHash.instanceId = Invoke-RestMethod -Uri "$awsMetaUriBase/instance-id"
            $awsMetaHash.localAddress = Invoke-RestMethod -Uri "$awsMetaUriBase/local-ipv4"
            $awsMetaHash.localHostname = Invoke-RestMethod -Uri "$awsMetaUriBase/local-hostname"
            $awsMetaHash.securityGroups = Invoke-RestMethod -Uri "$awsMetaUriBase/security-groups"
            $awsMetaHash.AMIId = Invoke-RestMethod -Uri "$awsMetaUriBase/ami-id"

            [PSCustomObject]$awsMetaHash
        }
        
    }
    
}

function get-prowlFileEncoding
{

    <#
        .SYNOPSIS
            Rewrite of the get-fileEncoding script from MS KnowledgeBase
            
        .DESCRIPTION
            The one supplied by MS is a bit of a mess
            
        ------------
        .EXAMPLE
            get-fileEncoding -path 'c:\example\file.txt'


        .EXAMPLE
            get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'


        .EXAMPLE
            $files = get-
            get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2020/12/16 - AA
                    - Rewrite
                        - Return an object
                        - Accept multiple paths
                        - work in PS 7
                        - Use system.IO over get-content
                        - Works with Get-ChildItem now as well

                    
    #>


    [CmdletBinding()]
    PARAM(
        #Path to the file
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Alias('Path')]
        [string[]]$FullName
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
    }
    
    process{
        foreach($item in $FullName)
        {
            remove-variable itemRef -ErrorAction SilentlyContinue

            write-verbose 'Checking file exists and is not a directory'
            $itemRef = get-item $item
            
            if(!$itemRef)
            {
                throw 'File does not exist'
            }

            #Check not directory
            if($itemRef.PsIsContainer -eq $true)
            {
                break
            }

            write-verbose 'Getting full path'
            $itemPath = $itemRef.FullName
    
            write-verbose 'Extracting content as Byte Array'
            #The old way - Slow and does not work in PS 7
            #[byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
    
            #New way
            [byte[]]$byte = [System.IO.File]::ReadAllBytes($itemPath)
            #MatchArray
    
            #Switch does not work here... Lots of IFs instead
            $returnHash = @{
                path = $itemPath
                bytes = $byte.Count
                
            }
            # EF BB BF (UTF8)
            if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf ) {
                write-verbose 'UTF8'
                $returnHash.encoding = 'UTF-8'
                $returnHash.endian = 'NA'
            }
    
            # FE FF  (UTF-16 Big-Endian)
            elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
            {
                write-verbose 'Unicode UTF-16 Big-Endian'
                $returnHash.encoding = 'UTF-16'
                $returnHash.endian = 'Big'
            }
            
            # FF FE  (UTF-16 Little-Endian)
            elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
            {
                write-verbose 'Unicode UTF-16 Little-Endian'
                $returnHash.encoding = 'UTF-16'
                $returnHash.endian = 'Little'
            }
            
            # 00 00 FE FF (UTF32 Big-Endian)
            elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
            {
                write-verbose 'UTF32 Big-Endian'
                $returnHash.encoding = 'UTF-32'
                $returnHash.endian = 'Big'
            }
            
            # FE FF 00 00 (UTF32 Little-Endian)
            elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0)
            {
                write-verbose 'UTF32 Little-Endian'
                $returnHash.encoding = 'UTF-32'
                $returnHash.endian = 'Little'
            }
            
            # 2B 2F 76 (38 | 38 | 2B | 2F)
            elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f) )
            {
                write-verbose 'UTF7'
                $returnHash.encoding = 'UTF-7'
                $returnHash.endian = 'NA'
            }
            
            # F7 64 4C (UTF-1)
            elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c )
            {
                write-verbose 'UTF-1'
                $returnHash.encoding = 'UTF-1'
                $returnHash.endian = 'NA'
            }
            
            # DD 73 66 73 (UTF-EBCDIC)
            elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73)
            {
                write-verbose 'UTF-EBCDIC'
                $returnHash.encoding = 'UTF-EBCDIC'
                $returnHash.endian = 'NA'
            }
            
            # 0E FE FF (SCSU)
            elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff )
            {
                Write-verbose 'SCSU'
                $returnHash.encoding = 'SCSU'
                $returnHash.endian = 'NA'
                
            }
            
            # FB EE 28  (BOCU-1)
            elseif ( $byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28 )
            {
                Write-verbose 'BOCU-1'
                $returnHash.encoding = 'BOCU-1'
                $returnHash.endian = 'NA'
                
            }
            
            # 84 31 95 33 (GB-18030)
            elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33)
            {
                Write-Verbose 'GB-18030'
                $returnHash.encoding = 'GB-18030'
                $returnHash.endian = 'NA'
            }
            
            #Assume ASCII if none of the above
            else
            {
                Write-Verbose 'Assuming ASCII'
                $returnHash.encoding = 'ASCII'
                $returnHash.endian = 'NA'
    
            }
    
    
           [psCustomObject]$returnHash 
        }
        
    }
    
}

function get-prowlInternetIpAddress
{

    <#
        .SYNOPSIS
            Query the AKAMAI URI for current IP
            
        .DESCRIPTION
            Invoke-webrequest against the AKAMAI page whatismyip.akamai.com
            Supports the /advanced path so you can get some more details about your IP
            
        ------------
        .EXAMPLE
            get-myIp
            
            #### OUTPUT
            180.80.180.80

        .EXAMPLE
            get-myIp -detailed
            
            #### OUTPUT
            180.80.180.80
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                yyyy-mm-dd - AA
                    - Changed x for y
                    
    #>

    [CmdletBinding()]
    PARAM(
        #Should we get some more details
        [Parameter()]
        [Alias("all")]
        [switch]$detailed
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $baseUri = 'http://whatismyip.akamai.com'

        function fixUtcStamp
        {
            param(
                [int32]$utcStamp
            )
            write-verbose "fixUtcStamp for: $utcStamp"
            #Need to convert the value supplied from EPOCH/UNIX to DateTime...
            #Issue is its going to be in the UTC zone
            #We can fudge this though
            $now = Get-Date
            $nowUTC = $now.ToUniversalTime()
            $utcDiff = $now - $nowUTC
            $epochStart = get-date 01.01.1970
            $epochAdjusted = $($epochStart.AddHours($utcDiff.Hours)).AddMinutes($utcDiff.Minutes)
            $epochAdjusted.AddSeconds($utcStamp)
        }
    }
    
    process{
        if($detailed)
        {
            write-verbose 'Getting Advanced IP Details'
            try{
                write-verbose 'Checking for, and importing PowerHTML'
                import-module PowerHTML
            }catch{
                throw 'PowerHTML Module not installed - try without the detailed information'
            }

            write-verbose 'Invoking Web Request'
            $page = "$baseUri/advanced"
            $wr = Invoke-WebRequest $page
            
            #Lets use PowerHTML so we can inspect the HTML and use XPATH and stuff
            write-verbose 'Extracting Details from HTML Object'
            $HtmlObj = $wr.content|convertFrom-html
            $textNodes = $htmlObj.childNodes[0].childNodes.where{$_.nodeType -eq 'Text'}
            $returnHash = @{}
            $textNodes.forEach{
                $split = $_.InnerText -split ': '
                $header = $split[0]
                $value = $split[1]
                switch ($header) {
                    'Server Time' {
                        write-verbose 'Fixing Server Date'

                        $value = fixUtcStamp $value
                    }
                    'Client Time' {
                        if(!$value)
                        {
                            write-verbose 'Adding Client Date'
                            #Since the client time is fudged from JavaScript we expect a null
                            #Lets just use the currentDateTime Instead of returning null
                            $value = get-date
                        }else{
                            write-verbose 'Fixing returned Client Date'
                            #If we somehow GOT a client time, convert it from Unix
                            $value = fixUtcStamp $value
                        }
                    }
                }
                $returnHash.$header = $value
            }
            write-verbose 'Should be good to go'
            [psCustomObject]$returnHash
            
        }else{
            write-verbose 'Getting Simple IP'
            Invoke-RestMethod $baseUri
        }
        
    }
    
}

function get-prowlUserAnalysis
{

    <#
        .SYNOPSIS
            Get an impression of the SecurityLog
            
        .DESCRIPTION
            Get an impression of the SecurityLog
            
            Needs to work on 2012 R2
        
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Init Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $logNames = @(
            'Security'
        )

        $userLoginTypeIds = @(
            4624
            4778
        )

        $logonType = @{
            0 = 'missingTypeId'
            1 = 'unknown1'
            2 = 'interactive'
            3 = 'network'
            4 = 'batch'
            5 = 'Service'
            6 = 'Unknown6'
            7 = 'Unlock'
            8 = 'NetworkClearText'
            9 = 'NewCredentials'
            10 = 'RemoteInteractive'
            11 = 'CachedInteractive'
        }
        

        
        $failedIds = @(
            4625
        )





    }
    
    process{
        if($(get-prowlAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }

        write-warning 'Getting Events: Could take a while'
        $events = Get-WinEvent -LogName $logNames

        write-verbose "EventCount: $($events|measure-object|Select-object -ExpandProperty count)"

        write-verbose 'Parsing Event Logs'
        $eventData = $events.foreach{
            $xml = [xml]$_.ToXml()
            $eventDataHash = @{}
            $xml.event.eventData.data.foreach{
                $eventDataHash."$($_.Name)" = "$($_.'#text')"
            }
        
            
            
            [psCustomObject]@{
                Id  = $_.Id
                TimeCreated = $_.TimeCreated
                #Msg = $_.Message
                EventRecordId = $xml.event.system.EventRecordId
                Task = $xml.event.system.Task
                eventData = [psCustomObject]$eventDataHash
            }
        }

        write-verbose 'Checking for log count anomalies'
        $recordMeasure = $eventData.eventRecordId|Measure-Object -Maximum -Minimum
        $recordCheck = ($recordMeasure.Maximum - $recordMeasure.Minimum)+1
        
        $recordIdAnomalyCount = $recordMeasure.count - $recordCheck
        
        if($recordIdAnomalyCount -ne 0)
        {
            write-warning "CHECK Records for Anomalies - IDs not consistent with COUNT - AnomalySum: $recordIdAnomalyCount"
        }

        write-verbose 'Checking User Login Activity'
        $userLogins = $eventData.where{$_.Id -in $userLoginTypeIds -and $_.eventData.TargetDomainName -ne 'NT AUTHORITY'}

        $loginSummary = $userLogins.ForEach{
            $typeId = [int]$_.EventData.LogonType
        
            [psCustomObject]@{
                id = $_.id
                TimeCreated = $_.TimeCreated
                EventRecordId = $_.EventRecordId
                UserName = "$($_.eventData.TargetDomainName)\$($_.eventData.TargetUserName)"
                ProcessName = $_.EventData.ProcessName
                IpAddress = $_.EventData.IpAddress
                LogonType = $logonType.$typeId
        
            }
        }

        
        $group = $loginSummary|Group-Object -Property UserName
        $loginGroupSummary = $group|foreach-object{
            $SortedGroup = $_.group|sort-object TimeCreated
            $FirstRecord = $SortedGroup[0]
            $lastRecord = $SortedGroup[-1]
            $IPArray = $($_.group.ipaddress|where-object{$_.length -gt 1}|select-object -Unique)
            [psCustomObject]@{
                Name = $_.name
                Count = $_.Count
                FirstLogon = $FirstRecord.TimeCreated
                LastLogon = $lastRecord.TimeCreated
                LastLogonIp = $lastRecord.IpAddress
                IPAddressCount = $($IPArray|measure-object).count
                IPAddresses = $IPArray -join ','
            }
        }


        write-verbose 'Checking Failed Login Activity'
        $failedLogins = $eventData.where{$_.Id -in $failedIds -and $_.eventData.TargetDomainName -ne 'NT AUTHORITY'}
        $failureSummary = $failedLogins.ForEach{
            $typeId = [int]$_.EventData.LogonType
        
            [psCustomObject]@{
                id = $_.id
                TimeCreated = $_.TimeCreated
                EventRecordId = $_.EventRecordId
                UserName = "$($_.eventData.TargetDomainName)\$($_.eventData.TargetUserName)"
                ProcessName = $_.EventData.ProcessName
                IpAddress = $_.EventData.IpAddress
                LogonType = $logonType.$typeId
        
            }
        }
        $group = $failureSummary|Group-Object -Property UserName
        $FailGroupSummary = $group|foreach-object{
            $SortedGroup = $_.group|sort-object TimeCreated
            $FirstRecord = $SortedGroup[0]
            $lastRecord = $SortedGroup[-1]
            $IPArray = $($_.group.ipaddress|where-object{$_.length -gt 1}|select-object -Unique)
            [psCustomObject]@{
                Name = $_.name
                Count = $_.Count
                FirstLogon = $FirstRecord.TimeCreated
                LastLogon = $lastRecord.TimeCreated
                LastLogonIp = $lastRecord.IpAddress
                IPAddressCount = $($IPArray|measure-object).count
                IPAddresses = $IPArray -join ','
            }
        }

        write-verbose 'Checking Local Accounts and Groups'


        $localUsers = Get-CimInstance -Class Win32_UserAccount -Filter  "LocalAccount='True' and Disabled='False'"
        
        $localAdminUsers = get-ciminstance win32_group -filter 'Name = "Administrators"'|Get-CimAssociatedInstance  -Association win32_groupuser
        $localAccountAdmins = $localUsers|where-object{$_.Caption -in $localAdminUsers.caption}


        write-verbose 'Summarising Findings'



        $sortedEvents = $events|sort-object -Property TimeCreated
        write-verbose 'Creating Summary Object'
        [psCustomObject]@{
            EventCount = $recordMeasure.count
            FirstEventId = $recordMeasure.Minumum
            LastEventId = $recordMeasure.Maximum
            AnomalyChecksum = $recordIdAnomalyCount
            FirstRecordDate = $sortedEvents[0].timeCreated
            LastRecordDate = $sortedEvents[-1].timeCreated
            LoginSuccessSummary = $loginGroupSummary
            LoginFailureSummary = $FailGroupSummary
            localUsers = $localUsers.caption
            localUserAdmins = $($localAccountAdmins|measure-object).count
            localAdminsAndGroups = $localAdminUsers.Caption
        }

    }
    
}



function get-prowlLog4jJars
{

    <#
        .SYNOPSIS
            Find all the jars on a computer. Check them for 'JndiLookup.class'
            Works with PowerShell 3 - 5 or 7+
            
        .DESCRIPTION
            Written to be as fast as possible, uses Robocopy to find the jars, and uses 5 threads to check the jar files

            Why did I make this:

                I read about a dozen scripts from various sources and all of them had some deficiencies:
                Some used workflows (so Windows Powershell only). 
                Lots used Get-ChildItem / gci/ls with -recurse - which is significantly slower
                Not many did the reading in parallel, and those that did were very version specific
                Lots wrote a log file, rather than return a list of files
                Some were very proprietary or did other stuff that I didn't like
            
            This one also excludes the weirdness that google drive does for local drives


            On my laptop this scans the entire drive (With planted positives) in:

            Pwsh 7.2: 39 seconds
            Powershell 5.1: 53 seconds
            
        ------------
        .EXAMPLE
            find-log4jJars -verbose
            
            #### DESCRIPTION
            1. Identify local disk drives
            2. Scan each drive for .jar files using robocopy (1 scan per drive)
            3. Use the select-string function to search each file for the jndilookup.class, return only uniques
            4. Return a list of any that matched the above
            
            
            #### OUTPUT
            C:\temp2\trueHits\log4j-core-2.0-beta9.jar
            C:\temp2\trueHits\log4j-core-2.10.0.jar
            C:\temp2\trueHits\log4j-core-2.11.0.jar
            C:\temp2\trueHits\log4j-core-2.12.0.jar
            C:\temp2\trueHits\log4j-core-2.3.jar
            C:\temp2\trueHits\log4j-core-2.14.0.jar
            C:\temp2\trueHits\log4j-core-2.9.1.jar
            
            
            
        .NOTES
            Author: Adrian Andersson
           
            
            Changelog:
            
                2022-01-05 - AA
                    - Initial Script
                    - Tested on laptop
                        Tested with PS 7.2 and 5.1
                    - Fix multiple drive issue with Ps 3..5 robocopy command
                    - Better info/workflow avoid when nothing to scan
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        
        $drives = try{
            #Try with get-ciminstance
            $(Get-CimInstance -classname Win32_logicaldisk -ErrorAction stop|where-object{$_.DriveType -eq 3 -and $_.VolumeName -ne 'Google Drive'}).DeviceId
        }catch{
            #Failover to wmi
            write-warning 'Failover to WMI - you really should upgrade your powershell version'
            $(Get-wmiObject -class Win32_logicaldisk -ErrorAction stop|where-object{$_.DriveType -eq 3 -and $_.VolumeName -ne 'Google Drive'}).DeviceId
        }

        write-verbose "Need to scan drives: $($drives -join '; ')"

        #Handle the different parallel options based on PS version
        #Throw on <3 or 6
        switch ($psversiontable.psversion.Major) {
            {$_ -eq 6} {
                    #Not sure what to do about version 6.... 
                    #For now, just upgrade or use Windows PowerShell
                    #Could rewrite to use runspaces but I am not sure I like this idea
                    throw 'Your on PS 6. Upgrade and use PS 7, or use Windows Powershell (5)' 
                }
            {$_ -lt 3} {
                    throw 'Please use a newer version of PowerShell'
                }

            {$_ -ge 7} {
                    write-warning 'Using the PowerShell 7 way'
                    #Find all the jar files
                    #Robocopy is faster than get-childitem - like, significantly so
                    write-verbose 'Finding all the jar files on this pc'
                    $jars = $drives|foreach-object -ThrottleLimit 3 -Parallel {
                        #$(get-childitem "$_\" -Filter '*.jar' -Recurse -ErrorAction Ignore -exclude 'C:\Windows').fullname
                        Robocopy "$_\" 'null' *.jar /l /njh /njs /ndl /ns /nc /fp /e /xj
                    }
                
                    #Filter the robocopy result to remove spacing and clean up emtpy strings
                    $jars = $jars.trim()|where-object{$_.length -gt 1}
                    write-verbose "count of Jars found:$($($jars|measure-object).count)"
                
                    #Scan the JAR Contents for jndiLookup class, return the paths where this is found
                    write-verbose 'Scanning the Jars for log4j - 5 files at a time'
                    $jars|foreach-object -ThrottleLimit 5 -Parallel {
                        select-string -path $_ 'JndiLookup.class' |select-object -ExpandProperty path -Unique
                    }
            
                }
            
                Default {
                    #Get the contents using workflows - which are gone in 6+
                    write-warning 'Using the Powershell 3..5 way'
                    
                    #Get the jars with jobs
                    #Lets hope theres not a million drives or we are going to really crush this poor little CPU
                    write-verbose 'Find all the jars with 1 job per disk drive'
                    $jobs = $drives.foreach{
                        $sblockString = "Robocopy `"$_\`" 'null' *.jar /l /njh /njs /ndl /ns /nc /fp /e /xj"
                        $sblock = [scriptblock]::create($sblockString)
                        start-job -ScriptBlock $sblock
                    }

                    #Wait for all our jobs to finish
                    write-verbose 'Waiting for our jobs'
                    wait-job -Id $jobs.Id|out-null

                    #Get the jobs

                    write-verbose 'Retrieving all our jobs'
                    $jars = receive-job -id $jobs.id
                    

                    #Filter the robocopy result to remove spacing and clean up emtpy strings
                    $jars = $jars.trim()|where-object{$_.length -gt 1}
                    write-verbose "count of Jars found:$($($jars|measure-object).count)"


                    if($($jars|measure-object).count -ge 1)
                    {
                        write-verbose 'Scanning the Jars for log4j - 5 files at a time'

                        #Wrap it in a script block to avoid compile error on PS6+
                        #Still hate how herestrings need to end on the first line
                        $workflowScript = @'
                        param (
                            [object[]]$jars
                        )
                        workflow get-wfJarContents {
                            param (
                                [string[]]$jarPath
                            )
                        
                            foreach  -parallel -throttleLimit 5 ($jar in $jarPath)
                            {
                                select-string -path $jar 'JndiLookup.class' |select-object -ExpandProperty path -Unique
                            }
                        
                        }
                        
                        get-wfJarContents -jarPath $jars
                        
    
'@
                        
                        try{
                            $workflowSB = [scriptblock]::create($workflowScript)
                            $workflowSB.invoke((,$jars))
                            
                        }catch{
                            write-warning 'Scriptblock Error or Workflows not supported'
                        }
                    }else{
                        write-warning 'No JARS found - nothing to scan'
                    }

                    
                }
        }
        
    }
    
}

function get-prowlNetworkConnections
{

    <#
        .SYNOPSIS
            Get TCP and UDP connections, the username, and process thats running them
            
        .DESCRIPTION
            Similar to get-networkConnections, but works on Windows 2012
            
        ------------
        .EXAMPLE
            get-networkConnections
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        if($(get-prowlAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }

        


        $adapters = (Get-NetAdapter|where-object{$_.Status -eq 'Up'}).name
        $activeIps = (get-netIpAddress|where-object{$_.InterfaceAlias -in $adapters}).ipAddress

        $netStat = netstat -a -n -o
        $regex = '\s+'

        $csvDataHeaders = @(
            'Blank'
            'Protocol'
            'LocalAddressPort'
            'ForeignAddressPort'
            'State'
            'PID'
        )

        $netstatCsvData = ($netstat|where-object{$_ -like '*TCP*' -or $_ -like '*UDP*'}) -replace $regex,','|ConvertFrom-Csv -Header $csvDataHeaders
        $portRegexMatch = '\:((?:.(?!:))+$)'
        $netStatObjects = $netstatCsvData|ForEach-Object{

            $localSplit = $_.LocalAddressPort -split $portRegexMatch
            $remoteAddSplit = $_.ForeignAddressPort -split $portRegexMatch

            if($_.Protocol -eq 'UDP')
            {
                [psCustomObject]@{
                    Protocol = $_.Protocol
                    LocalAddress = $localSplit[0]
                    localPort = $localSplit[1]
                    RemoteAddress = $remoteAddSplit[0]
                    RemotePort = $remoteAddSplit[1]
                    State = $null
                    OwningProcess = $_.State
                }
            }else{
                [psCustomObject]@{
                    Protocol = $_.Protocol
                    LocalAddress = $localSplit[0]
                    localPort = $localSplit[1]
                    RemoteAddress = $remoteAddSplit[0]
                    RemotePort = $remoteAddSplit[1]
                    State = $_.state
                    OwningProcess = $_.pid
                }
            }
            
        }

        $validConnections = ($netStatObjects|where-object{$_.localAddress -in $activeIps})

        $subSelect = @(
            'Protocol'
            'LocalAddress'
            'LocalPort'
            'RemoteAddress'
            'RemotePort'
            'State'
            @{
                name = 'Pid'
                expression = {$_.OwningProcess}
            }
            @{
                name = 'ProcessName'
                expression = {(Get-Process -Id $_.OwningProcess).ProcessName}
            }
            @{
                name = 'cmdPath'
                expression = {(Get-Process -Id $_.OwningProcess).path}
            }
            @{
                name = 'CmdLine'
                #expression = {(Get-Process -Id $_.OwningProcess).Commandline}
                expression = {$cimInst = get-cimINstance win32_process -filter "ProcessId = '$($_.OwningProcess)'";$cimInst.CommandLine}
            }
            @{
                name = 'username'
                expression = {$cimInst = get-cimINstance win32_process -filter "ProcessId = '$($_.OwningProcess)'";$owner = Invoke-CimMethod -InputObject $cimInst -MethodName GetOwner;"$($owner.Domain)\$($owner.User)"}
            }
        )

        $validConnections|Select-Object $subSelect
    }
    
}

function get-prowlNonMsServices
{

    <#
        .SYNOPSIS
            Get all the services that probably dont belong to Microsoft
            
        .DESCRIPTION
            Just need a brief way to get these services
            
        ------------
        .EXAMPLE
            
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Init Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $servicesSelect = @(
            'Name'
            'Pathname'
            'Started'
            'State'
            @{
                name = 'ProcessName'
                expression = {(Get-Process -Id $_.ProcessId).ProcessName}
            }
            @{
                name = 'CmdLine'
                expression = {(Get-Process -Id $_.ProcessId).Commandline}
            }
            @{
                name = 'username'
                expression = {$cimInst = get-cimINstance win32_process -filter "ProcessId = '$($_.ProcessId)'";$owner = Invoke-CimMethod -InputObject $cimInst -MethodName GetOwner;"$($owner.Domain)\$($owner.User)"}
            }
        )
    }
    
    process{
        if($(get-prowlAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }

        $ShortlistServices = Get-WmiObject win32_service | where-object { $_.Caption -notmatch "Windows" -and $_.PathName -notmatch "Windows" -and $_.PathName -notmatch "policyhost.exe" -and $_.Name -ne "LSM" -and $_.PathName -notmatch "OSE.EXE" -and $_.PathName -notmatch "OSPPSVC.EXE" -and $_.PathName -notmatch "Microsoft Security Client" }
        $ShortlistServices|select-object $servicesSelect
    }
    
}

function get-prowlSystemReport
{

    <#
        .SYNOPSIS
            Get all the data, dump to a text file
            
        .DESCRIPTION
            Get all the data, dump to a text file           
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(
        #PARAM DESCRIPTION
        [Parameter()]
        [string]$filePath = 'c:\psProwlReport.txt'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $header = @(
            '##### PROWL INSTANCE REPORT #####'
            "$(get-date -Format 'o')"
            "`n`n`n`n"
        )
    }
    
    process{
        if($(get-prowlAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }

        $stopwatch = [system.diagnostics.stopwatch]::StartNew()

        $header -join "`n"|out-file $filePath


        "++++OS DATA++++`n"|out-file $filePath -Append -NoClobber


        $os = get-prowlWindowsOsData
        "_-OS Details-_`n"|out-file $filePath -Append -NoClobber
        $os.winOs|format-list|out-string|out-file $filePath -Append -NoClobber
        
        "_-OS LastUpdate-_`n"|out-file $filePath -Append -NoClobber
        $os.LastUpdate|out-file $filePath -Append -NoClobber

        "_-OS Hotfixes-_`n"|out-file $filePath -Append -NoClobber
        $os.Hotfix|format-table|out-string|out-file $filePath -Append -NoClobber

        "_-OS Drives-_`n"|out-file $filePath -Append -NoClobber
        $os.Drives|format-table|out-string|out-file $filePath -Append -NoClobber

        "_-INTERNET IP-_`n"|out-file $filePath -Append -NoClobber
        get-prowlInternetIpAddress|out-string|out-file $filePath -Append -NoClobber

        "_-PowerShell Version - Used in Execute_`n"|out-file $filePath -Append -NoClobber
        $PSVersionTable|Format-Table|out-string|out-file $filePath -Append -NoClobber

        "++++AWS DATA++++`n"|out-file $filePath -Append -NoClobber
        $(get-prowlAwsMetaData)|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++ANTI VIRUS++++`n"|out-file $filePath -Append -NoClobber
        $(Get-prowlAntivirusProducts)|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++USER DATA++++`n"|out-file $filePath -Append -NoClobber
        $userData = get-prowlUserAnalysis
        "_-User Details-_`n"|out-file $filePath -Append -NoClobber
        $userData|Select-object EventCount,FirstEventId,LastEventId,AnomalyCheckSum,FirstRecordDate,LastRecordDate,LocalUserAdmins|format-List|out-string|out-file $filePath -Append -NoClobber

        "_-Local Users-_`n"|out-file $filePath -Append -NoClobber
        $userData.localUsers|format-list|out-string|out-file $filePath -Append -NoClobber

        "_-Admins and Admin Groups-_`n"|out-file $filePath -Append -NoClobber
        $userData.localAdminsAndGroups|format-list|out-string|out-file $filePath -Append -NoClobber

        "_-Login Success Summary-_`n"|out-file $filePath -Append -NoClobber
        $userData.LoginSuccessSummary|format-list|out-string|out-file $filePath -Append -NoClobber

        "_-Login Failure Summary-_`n"|out-file $filePath -Append -NoClobber
        $userData.LoginFailureSummary|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++SERVICES++++`n"|out-file $filePath -Append -NoClobber
        $(get-prowlNonMsServices)|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++NETWORK CONNECTIONS++++`n"|out-file $filePath -Append -NoClobber
        $(get-prowlNetworkConnections)|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++Active ScheduledTasks++++`n"|out-file $filePath -Append -NoClobber
        $(get-prowlScheduledTasks)|format-list|out-string|out-file $filePath -Append -NoClobber

        "++++LOG4J Risks++++`n"|out-file $filePath -Append -NoClobber
        if($PSVersionTable.PSVersion -gt [version]::Parse('3.0.0'))
        {
            $(get-prowlLog4jJars)|format-list|out-string|out-file $filePath -Append -NoClobber
        }else{
            write-warning 'Your version of PowerShell is not going to work for checking log4j'
        }

        $stopwatch.Stop()
        "##### PROWL INSTANCE REPORT - END #####`n`nTimeToComplete: $($stopwatch.Elapsed.ToString())`n"|out-file $filePath -Append -NoClobber
    }
    
}

Function Get-RebootHistory {
    <#
    .SYNOPSIS
        This will output who initiated a reboot or shutdown event.
     
    .NOTES
        Name: Get-RebootHistory
        Author: theSysadminChannel
        Version: 1.0
        DateCreated: 2020-Aug-5
     
    .LINK
        https://thesysadminchannel.com/get-reboot-history-using-powershell -
     
    .EXAMPLE
        Get-RebootHistory -ComputerName Server01, Server02
     
    .EXAMPLE
        Get-RebootHistory -DaysFromToday 30 -MaxEvents 1
     
    .PARAMETER ComputerName
        Specify a computer name you would like to check.  The default is the local computer
     
    .PARAMETER DaysFromToday
        Specify the amount of days in the past you would like to search for
     
    .PARAMETER MaxEvents
        Specify the number of events you would like to search for (from newest to oldest)
    #>
     
     
        [CmdletBinding()]
        param(
            [Parameter(
                Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true
            )]
            [string[]]  $ComputerName = $env:COMPUTERNAME,
     
            [int]       $DaysFromToday = 7,
     
            [int]       $MaxEvents = 9999
        )
     
        BEGIN {}
     
        PROCESS {
            foreach ($Computer in $ComputerName) {
                try {
                    $Computer = $Computer.ToUpper()
                    $EventList = Get-WinEvent -ComputerName $Computer -FilterHashtable @{
                        Logname = 'system'
                        Id = '1074', '6008'
                        StartTime = (Get-Date).AddDays(-$DaysFromToday)
                    } -MaxEvents $MaxEvents -ErrorAction Stop
     
     
                    foreach ($Event in $EventList) {
                        if ($Event.Id -eq 1074) {
                            [PSCustomObject]@{
                                TimeStamp    = $Event.TimeCreated
                                ComputerName = $Computer
                                UserName     = $Event.Properties.value[6]
                                ShutdownType = $Event.Properties.value[4]
                            }
                        }
     
                        if ($Event.Id -eq 6008) {
                            [PSCustomObject]@{
                                TimeStamp    = $Event.TimeCreated
                                ComputerName = $Computer
                                UserName     = $null
                                ShutdownType = 'unexpected shutdown'
                            }
                        }
     
                    }
     
                } catch {
                    Write-Error $_.Exception.Message
     
                }
            }
        }
     
        END {}
    }

function get-prowlScheduledTasks
{

    <#
        .SYNOPSIS
            Simple description
            
        .DESCRIPTION
            Detailed Description
            
        ------------
        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                yyyy-mm-dd - AA
                    - Changed x for y
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"


        
        <#
        $stSelect = @(
            'Taskname'
            'State'
            'TaskPath'
            @{
                Name = 'Hidden'
                Expression = {$_.Settings.Hidden}
            }
            @{
                Name = 'TriggerCount'
                Expression = {($_.triggers|measure-object).count}
            }
            @{
                Name = 'TriggerUsers'
                #Expression = {($_.triggers.UserId -join '; ')}
                Expression = {
                    foreach($t in $_.triggers)
                    {
                        "[User: $($t.UserId); Interval: $($t.Interval)]"
                    } -join '; '
                }
            }
            @{
                Name = 'Execute'
                Expression = {"$($_.Actions.Execute) $($_.Actions.Arguments)"}
            }
            @{
                Name = 'Statistics'
                Expression = {$stInfo = Get-ScheduledTaskInfo -TaskName $_.TaskName;"LastRun: $($stInfo.LastRunTime); LastRes: $($stInfo.LastTaskResult); NextRun: $($stInfo.NextRunTime); "}
            }
        )
        #>
    }
    
    process{
        
        $activeScheduledTasks = (get-scheduledTask).where{$_.state -ne 'Disable' -and $_.Author -ne 'Microsoft Corporation' -and $_.Taskname -notlike 'packer*'}
        foreach($stask in $activeScheduledTasks)
        {
            $stInfo = try{
                Get-ScheduledTaskInfo -TaskName $stask.TaskName -ErrorAction stop
            }catch{
                $null
            }
            $triggerUsers = $(foreach($t in $stask.triggers)
            {
                if($t.userId -and $t.Interval)
                {
                    "[User: $($t.UserId); Interval: $($t.Interval)]"
                }
                
            } -join '; ')
            $triggerCount = ($stask.triggers|measure-object).count
            if($stInfo.LastRunTime -or $stInfo.NextRunTime -or $sTask.state -ne 'Ready')
            {
                [PSCustomObject]@{
                    TaskName = $stask.Taskname
                    State = $sTask.state
                    TaskPath = $sTask.TaskPath
                    Hidden = $sTask.Settings.Hidden
                    TriggerCount = $triggerCount
                    TriggerUsers = $triggerUsers
                    Execute = "$($stask.Actions.Execute) $($stask.Actions.Arguments)"
                    LastRun = $stInfo.LastRunTime
                    LastResult = $stInfo.LastTaskResult
                    NextRun = $stInfo.NextRunTime
                }
            }
        }
        #$activeScheduledTasks | Select-Object $stSelect
    }
    
}


<#NOTE FOR FUTURE SELF
Writen: 2022.08.02 - Need to finish this task off, its not working wht the custom select and Im not sure why
Its failing to expand the task details

Might just use add-properties or something

#>

function get-prowlVirusTotalFileHashDetails
{

    <#
        .SYNOPSIS
            Find a file, grab its hash, send to VirusTotal to get the ID results
            
        .DESCRIPTION
            Find a file, grab its hash, send to VirusTotal to get the ID results

            Currently in a bit of a PoC 
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(
        #PARAM DESCRIPTION
        [Parameter(Mandatory)]
        [string]$virusTotalAPI,
        [parameter(mandatory)]
        [string]$filePath
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $header = @{
            'x-apikey' = $apiKey
        }
        
        $uriHash = 'https://www.virustotal.com/api/v3/files'
    }
    
    process{
        if(!(test-path $filePath))
        {
            throw 'File not found'
        }
        
        
        $fileHash = get-fileHash $filePath
        
        $fullUri = "$uriHash/$($fileHash.hash)"
        
        $rest = invoke-restMethod -uri $fullUri -header $header
        
        $rest
    }
    
}

function get-prowlAdminStatus
{

    <#
        .SYNOPSIS
            Simple function to check if this Windows PowerShell Prompt is running with Admin privelages
            
        .DESCRIPTION
            Simple function to check if this Windows PowerShell Prompt is running with Admin privelages

            Check this blog for more details on Security Principals in PowerShell
            https://devblogs.microsoft.com/scripting/check-for-admin-credentials-in-a-powershell-script/
            
        ------------
        .EXAMPLE
            get-adminStatus            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2020-12-17 - AA
                    - First Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        write-verbose 'Getting Administrator Status from SecurityPrincipal'
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        $isAdmin
    }
    
}

function get-prowlWindowsOsData
{

    <#
        .SYNOPSIS
            Get some basic windows data like updates and stuff
            
        .DESCRIPTION
            Get some basic windows data like updates and stuffs
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $winOsSelect = @(
            'Name'
            'Version'
            'TotalVisibleMemorySize'
            'LastBootUpTime'
            'InstallDate'
            'CSName'
            'Organization'
            'OSArchitecture'
        )

        $hotfixSelect = @(
            'Description'
            'HotfixId'
            'InstalledBy'
            'InstalledOn'
        )

        $psDriveSelect = @(
            @{
                Name = 'Drive'
                Expression = {$_.Root}
            }
            @{
                Name = 'Size_GB'
                Expression = {[math]::round(($_.Used + $_.Free)/1gb,2)}
            }
            @{
                Name = 'Free_GB'
                Expression = {[math]::round($_.Free/1gb,2)}
            }
        )

    }
    
    process{

        $returnHash = @{}
        $returnHash.winOs = get-ciminstance win32_operatingSystem|Select-Object $winOsSelect
        $returnHash.Hotfix = get-hotfix|select-object $hotfixSelect
        $returnHash.LastUpdate = $($returnHash.Hotfix|sort-object 'InstalledOn' -Descending | Select-Object -First 1).InstalledOn
        $returnHash.Drives = get-psdrive|where-object {$_.Provider -like '*FileSystem*'}|Select-Object $psDriveSelect
        [pscustomObject]$returnHash
    }

    
}

<# 
1..10000000|%{
    shutdown /a
    start-sleep -seconds 1
}

#>

function stop-shutdown
{
    while ($([System.Environment]::HasShutdownStarted) -eq $true)
    {
        write-warning 'Shutdown Detected - Running Abort, sleeping for 2 seconds and checking again'
        shutdown /a
        start-sleep -seconds 2
    }

    if($([System.Environment]::HasShutdownStarted) -eq $true)
    {
        write-warning 'Shutdown still triggered'
    }else{
        write-warning 'No Shutdown currently scheduled'
    }
    
}

