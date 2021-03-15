function get-prowlNetworkConnections
{

    <#
        .SYNOPSIS
            Get TCP and UDP connections, the username, and process thats running them
            
        .DESCRIPTION
            Get TCP and UDP connections, the username, and process thats running them

            This function does not work too well on win 2012, so we will keep it but use a different one
            
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
        if($(get-winAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }
        $adapters = (Get-NetAdapter|where-object{$_.Status -eq 'Up'}).name
        $activeIps = (get-netIpAddress|where-object{$_.InterfaceAlias -in $adapters}).ipAddress
        $validConnections = (Get-NetTCPConnection|where-object{$_.localAddress -in $activeIps})
        $validConnections | add-member -MemberType noteproperty -Name 'Protocol' -Value 'TCP'

        #Need to get the UDPs as well

        $udpConnections = (Get-NetUDPEndpoint|where-object{$_.localAddress -in $activeIps -or $_.LocalAddress -eq '0.0.0.0' -or $_.localAddress -eq '[::]'})
        $udpSelect = @(
            @{
                Name = 'Protocol'
                Expression = {
                'UDP'
                }
            }
            @{
                Name = 'RemoteAddress'
                Expression = {
                    if($_.RemoteAddress)
                    {
                        $_.RemoteAddress
                    }else{
                        '*'
                    }
                }
            }
            @{
                Name = 'RemotePort'
                Expression = {
                    if($_.RemotePort)
                    {
                        $_.RemotePort
                    }else{
                        '*'
                    }
                }
            }
            'OwningProcess'
            'LocalAddress'
            'LocalPort'
            @{
                Name = 'State'
                Expression = {
                    if($_.status)
                    {
                        $_.status
                    }else{
                        '?'
                    }
                }
            }
        )
        $validConnections += $($udpConnections|select-object $udpSelect)


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
                name = 'CmdLine'
                expression = {(Get-Process -Id $_.OwningProcess).Commandline}
            }
            @{
                name = 'ProcessName'
                expression = {(Get-Process -Id $_.OwningProcess).ProcessName}
            }
            @{
                name = 'username'
                expression = {$cimInst = get-cimINstance win32_process -filter "ProcessId = '$($_.OwningProcess)'";$owner = Invoke-CimMethod -InputObject $cimInst -MethodName GetOwner;"$($owner.Domain)\$($owner.User)"}
            }
        )

        $validConnections|Select-Object $subSelect

        
    }
    
}