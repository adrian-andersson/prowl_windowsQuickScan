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