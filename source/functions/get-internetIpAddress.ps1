function get-prowlInternetIpAddress
{

    <#
        .SYNOPSIS
            Query the AKAMAI URI for current IP
            
        .DESCRIPTION
            Invoke-webrequest against the AKAMAI page whatismyip.akamai.com
            Supports the /advanced path so you can get some more details about your IP
            
        ------------
        .EXAMPLE
            get-myIp
            
            #### OUTPUT
            180.80.180.80

        .EXAMPLE
            get-myIp -detailed
            
            #### OUTPUT
            180.80.180.80
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                yyyy-mm-dd - AA
                    - Changed x for y
                    
    #>

    [CmdletBinding()]
    PARAM(
        #Should we get some more details
        [Parameter()]
        [Alias("all")]
        [switch]$detailed
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $baseUri = 'http://whatismyip.akamai.com'

        function fixUtcStamp
        {
            param(
                [int32]$utcStamp
            )
            write-verbose "fixUtcStamp for: $utcStamp"
            #Need to convert the value supplied from EPOCH/UNIX to DateTime...
            #Issue is its going to be in the UTC zone
            #We can fudge this though
            $now = Get-Date
            $nowUTC = $now.ToUniversalTime()
            $utcDiff = $now - $nowUTC
            $epochStart = get-date 01.01.1970
            $epochAdjusted = $($epochStart.AddHours($utcDiff.Hours)).AddMinutes($utcDiff.Minutes)
            $epochAdjusted.AddSeconds($utcStamp)
        }
    }
    
    process{
        if($detailed)
        {
            write-verbose 'Getting Advanced IP Details'
            try{
                write-verbose 'Checking for, and importing PowerHTML'
                import-module PowerHTML
            }catch{
                throw 'PowerHTML Module not installed - try without the detailed information'
            }

            write-verbose 'Invoking Web Request'
            $page = "$baseUri/advanced"
            $wr = Invoke-WebRequest $page
            
            #Lets use PowerHTML so we can inspect the HTML and use XPATH and stuff
            write-verbose 'Extracting Details from HTML Object'
            $HtmlObj = $wr.content|convertFrom-html
            $textNodes = $htmlObj.childNodes[0].childNodes.where{$_.nodeType -eq 'Text'}
            $returnHash = @{}
            $textNodes.forEach{
                $split = $_.InnerText -split ': '
                $header = $split[0]
                $value = $split[1]
                switch ($header) {
                    'Server Time' {
                        write-verbose 'Fixing Server Date'

                        $value = fixUtcStamp $value
                    }
                    'Client Time' {
                        if(!$value)
                        {
                            write-verbose 'Adding Client Date'
                            #Since the client time is fudged from JavaScript we expect a null
                            #Lets just use the currentDateTime Instead of returning null
                            $value = get-date
                        }else{
                            write-verbose 'Fixing returned Client Date'
                            #If we somehow GOT a client time, convert it from Unix
                            $value = fixUtcStamp $value
                        }
                    }
                }
                $returnHash.$header = $value
            }
            write-verbose 'Should be good to go'
            [psCustomObject]$returnHash
            
        }else{
            write-verbose 'Getting Simple IP'
            Invoke-RestMethod $baseUri
        }
        
    }
    
}