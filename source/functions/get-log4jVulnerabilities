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