function get-prowlLogonHistory
{

    <#
        .SYNOPSIS
            Try and get the logon history of a machine
            
        .DESCRIPTION
            Try and get the logon history of a machine
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-21 - AA
                    - Taken from https://adamtheautomator.com/user-logon-event-id/ and reworked
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"


        $sessionEvents = @(
            @{ 'Label' = 'Logon'; 'EventType' = 'SessionStart'; 'LogName' = 'Security'; 'ID' = 4624 } ## Advanced Audit Policy --> Audit Logon
            @{ 'Label' = 'RdpSessionReconnect'; 'EventType' = 'SessionStart'; 'LogName' = 'Security'; 'ID' = 4778 } ## Advanced Audit Policy --> Audit Other Logon/Logoff Events
        )

        enum logonType{
            missingTypeId
            unknown1
            interactive
            network
            batch
            unknown6
            service
            unlock
            networkcleartext
            newcredential
            remoteinteractive
            cachedinteractive
        }


         ## All of the IDs that designate when user activity starts
        $sessionStartIds = ($sessionEvents | where-object { $_.EventType -eq 'SessionStart' }).ID
        ## All of the IDs that designate when user activity stops
        $sessionStopIds = ($sessionEvents | where-object { $_.EventType -eq 'SessionStop' }).ID


        ## Define all of the log names we'll be querying
        $logNames = ($sessionEvents.LogName | select-object -Unique)
        ## Grab all of the interesting IDs we'll be looking for
        $ids = $sessionEvents.Id


        ## Build the insane XPath query for the security event log in order to query events as fast as possible
        #$logonXPath = "Event[System[EventID=4624]] and Event[EventData[Data[@Name='TargetDomainName'] != 'Window Manager']] and Event[EventData[Data[@Name='TargetDomainName'] != 'NT AUTHORITY']] and (Event[EventData[Data[@Name='LogonType'] = '2']] or Event[EventData[Data[@Name='LogonType'] = '11']] )"
        #$otherXpath = 'Event[System[({0})]]' -f "EventID=$(($ids.where({ $_ -ne '4624' })) -join ' or EventID=')"
        #$xPath = '({0}) or ({1})' -f $logonXPath, $otherXpath
        $xpath = "(Event[System[EventID=4624]] or Event[System[EventID=4778]]) and (Event[EventData[Data[@Name='TargetDomainName'] != 'Window Manager']] and Event[EventData[Data[@Name='TargetDomainName'] != 'NT AUTHORITY']])"# 4778,4624
        #$xpath = "Event[System[EventID=4624]] OR Event[System[EventID=4778]]"
        #$xPath = "Event[System[EventID=4624]] or Event[System[EventID=4778]]"
        #$xPath = "Event[System[EventID=4778]]"
    }
    
    process{
        $events = Get-WinEvent -LogName $logNames -FilterXPath $xPath
        Write-Verbose -Message "Found [$($events.Count)] events to look through"

        $loggedInUsers = (Get-CimInstance 'Win32_ComputerSystem').UserName

        $events.foreach{
            $xml = [xml]$_.ToXml()
            $eventDataHash = @{}
            $xml.event.eventData.data.foreach{
                $eventDataHash."$($_.Name)" = "$($_.'#text')"
            }

            
            
            [psCustomObject]@{
                Id  = $_.Id
                TimeCreated = $_.TimeCreated
                Msg = $_.Message
                EventRecordId = $xml.event.system.EventRecordId

            }
        }

        #Get the full domain
        #$loggedInUsers = Get-CimInstance 'Win32_ComputerSystem' | Select-Object -ExpandProperty UserName
        
        ## Find all user start activity events and begin parsing
        $results = $events.where({ $_.Id -in $sessionStartIds }).foreach({
            try {
                $logonEvtId = $_.Id
                $output.StartAction = $sessionEvents.where({ $_.ID -eq $logonEvtId }).Label
                
                $xEvt = [xml]$_.ToXml()
                #$global:debugxEvt = $xEvt

                


                ## Figure out the login session ID
                $output.Username = ($xEvt.Event.EventData.Data | where { $_.Name -eq 'TargetUserName' }).'#text'
                $logonId = ($xEvt.Event.EventData.Data | where { $_.Name -eq 'TargetLogonId' }).'#text'
                if (-not $logonId) {
                    $logonId = ($xEvt.Event.EventData.Data | where { $_.Name -eq 'LogonId' }).'#text'
                }
                $logonType = ($xEvt.Event.EventData.Data|where {$_.name -eq 'LogonType'}).'#text'
                if(!$logonType)
                {
                    $logonType = 0
                }
                $output.logonType = ([logontype]$($logonType)).ToString()
                $output.StartTime = $_.TimeCreated
                $output.StartId = $logonEvtId
    
                Write-Verbose -Message "New session start event found: event ID [$($logonEvtId)] username [$($output.Username)] logonID [$($logonId)] time [$($output.StartTime)]"
                

                ## Try to match up the user activity end event with the start event we're processing
                if (-not ($sessionEndEvent = $Events.where({ ## If a user activity end event could not be found, assume the user is still logged on
                                $_.TimeCreated -gt $output.StartTime -and
                                $_.ID -in $sessionStopIds -and
                                (([xml]$_.ToXml()).Event.EventData.Data | Where-Object { $_.Name -eq 'TargetLogonId' }).'#text' -eq $logonId
                            })) | select-object -last 1) {
                    if ($output.UserName -in $loggedInUsers) {
                        $output.StopTime = Get-Date
                        $output.StopAction = 'Still logged in'
                    } else {
                        #throw "Could not find a session end event for logon ID [$($logonId)]."
                        $output.StopTime = $(get-date 9999/12/12)
                        $output.StopAction = 'Unknown'
                    }
                } else {
                    ## Capture the user activity end time
                    $output.StopTime = $sessionEndEvent.TimeCreated
                    Write-Verbose -Message "Session stop ID is [$($sessionEndEvent.Id)]"
                    $output.StopAction = $sessionEvents.where({ $_.ID -eq $sessionEndEvent.Id }).Label
                }

                $sessionTimespan = New-TimeSpan -Start $output.StartTime -End $output.StopTime
                $output.'Session Active (Days)' = [math]::Round($sessionTimespan.TotalDays, 2)
                $output.'Session Active (Min)'  = [math]::Round($sessionTimespan.TotalMinutes, 2)
                
                [pscustomobject]$output
            }catch{
                Write-Warning -Message $_.Exception.Message
                #write-warning 'Unable to process event'
            }
            #Sort our objects nicely
        })
        $results |Sort-Object -Property starttime,startaction,stoptime,stopaction,username,'Session Active (Days)','Session Active (Min)',StartId,logonType -Unique -Descending
    }
}
