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