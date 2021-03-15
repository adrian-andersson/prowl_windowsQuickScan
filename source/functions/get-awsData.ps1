function get-prowlAwsMetaData
{

    <#
        .SYNOPSIS
            Get all the AWS MetaData if the URI exists
            
        .DESCRIPTION
            Get all the AWS MetaData if the URI exists
            
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
        $awsMetaUriBase = 'http://169.254.169.254/latest/meta-data/'
    }
    
    process{
        try{
            $rm = Invoke-RestMethod -Uri $awsMetaUriBase
        }catch{
            write-warning "$($_.Exception.Message)"
            return
        }

        if($rm)
        {
            $awsMetaHash = @{}
            $awsMetaHash.instanceId = Invoke-RestMethod -Uri "$awsMetaUriBase/instance-id"
            $awsMetaHash.localAddress = Invoke-RestMethod -Uri "$awsMetaUriBase/local-ipv4"
            $awsMetaHash.localHostname = Invoke-RestMethod -Uri "$awsMetaUriBase/local-hostname"
            $awsMetaHash.securityGroups = Invoke-RestMethod -Uri "$awsMetaUriBase/security-groups"
            $awsMetaHash.AMIId = Invoke-RestMethod -Uri "$awsMetaUriBase/ami-id"

            [PSCustomObject]$awsMetaHash
        }
        
    }
    
}