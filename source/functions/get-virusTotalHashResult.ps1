function get-prowlVirusTotalFileHashDetails
{

    <#
        .SYNOPSIS
            Find a file, grab its hash, send to VirusTotal to get the ID results
            
        .DESCRIPTION
            Find a file, grab its hash, send to VirusTotal to get the ID results

            Currently in a bit of a PoC 
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2021-03-15 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(
        #PARAM DESCRIPTION
        [Parameter(Mandatory)]
        [string]$virusTotalAPI,
        [parameter(mandatory)]
        [string]$filePath
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $header = @{
            'x-apikey' = $apiKey
        }
        
        $uriHash = 'https://www.virustotal.com/api/v3/files'
    }
    
    process{
        if(!(test-path $filePath))
        {
            throw 'File not found'
        }
        
        
        $fileHash = get-fileHash $filePath
        
        $fullUri = "$uriHash/$($fileHash.hash)"
        
        $rest = invoke-restMethod -uri $fullUri -header $header
        
        $rest
    }
    
}