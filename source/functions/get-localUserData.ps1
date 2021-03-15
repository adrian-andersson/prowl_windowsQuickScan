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


