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