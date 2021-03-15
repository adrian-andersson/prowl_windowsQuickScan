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
                name = 'CmdLine'
                expression = {(Get-Process -Id $_.OwningProcess).Commandline}
            }
            @{
                name = 'username'
                expression = {$cimInst = get-cimINstance win32_process -filter "ProcessId = '$($_.OwningProcess)'";$owner = Invoke-CimMethod -InputObject $cimInst -MethodName GetOwner;"$($owner.Domain)\$($owner.User)"}
            }
        )

        $validConnections|Select-Object $subSelect
    }
    
}