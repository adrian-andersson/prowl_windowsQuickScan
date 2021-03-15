function get-prowlFileEncoding
{

    <#
        .SYNOPSIS
            Rewrite of the get-fileEncoding script from MS KnowledgeBase
            
        .DESCRIPTION
            The one supplied by MS is a bit of a mess
            
        ------------
        .EXAMPLE
            get-fileEncoding -path 'c:\example\file.txt'


        .EXAMPLE
            get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'


        .EXAMPLE
            $files = get-
            get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2020/12/16 - AA
                    - Rewrite
                        - Return an object
                        - Accept multiple paths
                        - work in PS 7
                        - Use system.IO over get-content
                        - Works with Get-ChildItem now as well

                    
    #>


    [CmdletBinding()]
    PARAM(
        #Path to the file
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Alias('Path')]
        [string[]]$FullName
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
    }
    
    process{
        foreach($item in $FullName)
        {
            remove-variable itemRef -ErrorAction SilentlyContinue

            write-verbose 'Checking file exists and is not a directory'
            $itemRef = get-item $item
            
            if(!$itemRef)
            {
                throw 'File does not exist'
            }

            #Check not directory
            if($itemRef.PsIsContainer -eq $true)
            {
                break
            }

            write-verbose 'Getting full path'
            $itemPath = $itemRef.FullName
    
            write-verbose 'Extracting content as Byte Array'
            #The old way - Slow and does not work in PS 7
            #[byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
    
            #New way
            [byte[]]$byte = [System.IO.File]::ReadAllBytes($itemPath)
            #MatchArray
    
            #Switch does not work here... Lots of IFs instead
            $returnHash = @{
                path = $itemPath
                bytes = $byte.Count
                
            }
            # EF BB BF (UTF8)
            if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf ) {
                write-verbose 'UTF8'
                $returnHash.encoding = 'UTF-8'
                $returnHash.endian = 'NA'
            }
    
            # FE FF  (UTF-16 Big-Endian)
            elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
            {
                write-verbose 'Unicode UTF-16 Big-Endian'
                $returnHash.encoding = 'UTF-16'
                $returnHash.endian = 'Big'
            }
            
            # FF FE  (UTF-16 Little-Endian)
            elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
            {
                write-verbose 'Unicode UTF-16 Little-Endian'
                $returnHash.encoding = 'UTF-16'
                $returnHash.endian = 'Little'
            }
            
            # 00 00 FE FF (UTF32 Big-Endian)
            elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
            {
                write-verbose 'UTF32 Big-Endian'
                $returnHash.encoding = 'UTF-32'
                $returnHash.endian = 'Big'
            }
            
            # FE FF 00 00 (UTF32 Little-Endian)
            elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0)
            {
                write-verbose 'UTF32 Little-Endian'
                $returnHash.encoding = 'UTF-32'
                $returnHash.endian = 'Little'
            }
            
            # 2B 2F 76 (38 | 38 | 2B | 2F)
            elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f) )
            {
                write-verbose 'UTF7'
                $returnHash.encoding = 'UTF-7'
                $returnHash.endian = 'NA'
            }
            
            # F7 64 4C (UTF-1)
            elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c )
            {
                write-verbose 'UTF-1'
                $returnHash.encoding = 'UTF-1'
                $returnHash.endian = 'NA'
            }
            
            # DD 73 66 73 (UTF-EBCDIC)
            elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73)
            {
                write-verbose 'UTF-EBCDIC'
                $returnHash.encoding = 'UTF-EBCDIC'
                $returnHash.endian = 'NA'
            }
            
            # 0E FE FF (SCSU)
            elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff )
            {
                Write-verbose 'SCSU'
                $returnHash.encoding = 'SCSU'
                $returnHash.endian = 'NA'
                
            }
            
            # FB EE 28  (BOCU-1)
            elseif ( $byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28 )
            {
                Write-verbose 'BOCU-1'
                $returnHash.encoding = 'BOCU-1'
                $returnHash.endian = 'NA'
                
            }
            
            # 84 31 95 33 (GB-18030)
            elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33)
            {
                Write-Verbose 'GB-18030'
                $returnHash.encoding = 'GB-18030'
                $returnHash.endian = 'NA'
            }
            
            #Assume ASCII if none of the above
            else
            {
                Write-Verbose 'Assuming ASCII'
                $returnHash.encoding = 'ASCII'
                $returnHash.endian = 'NA'
    
            }
    
    
           [psCustomObject]$returnHash 
        }
        
    }
    
}