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
                Expression = {$stInfo = Get-ScheduledTaskInfo -TaskName $_.TaskName;$global:stDebug = $stInfo;"LastRun: $($stInfo.LastRunTime); LastRes: $($stInfo.LastTaskResult); NextRun: $($stInfo.NextRunTime); "}
            }
        )
          
    }
    
    process{
        $activeScheduledTasks = (get-scheduledTask).where{$_.state -ne 'Disable' -and $_.Author -ne 'Microsoft Corporation'}
        $activeScheduledTasks | Select-Object $stSelect
    }
    
}


<#NOTE FOR FUTURE SELF
Writen: 2022.08.02 - Need to finish this task off, its not working wht the custom select and Im not sure why
Its failing to expand the task details

Might just use add-properties or something

#>