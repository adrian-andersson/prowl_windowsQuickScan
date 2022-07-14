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
            "`n`n`n`n"
        )
    }
    
    process{
        if($(get-prowlAdminStatus) -ne $true)
        {
            throw 'Not Elevated'
        }

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
        
    }
    
}