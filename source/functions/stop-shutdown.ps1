<# 
1..10000000|%{
    shutdown /a
    start-sleep -seconds 1
}

#>

function stop-shutdown
{
    while ($([System.Environment]::HasShutdownStarted) -eq $true)
    {
        write-warning 'Shutdown Detected - Running Abort, sleeping for 2 seconds and checking again'
        shutdown /a
        start-sleep -seconds 2
    }

    if($([System.Environment]::HasShutdownStarted) -eq $true)
    {
        write-warning 'Shutdown still triggered'
    }else{
        write-warning 'No Shutdown currently scheduled'
    }
    
}