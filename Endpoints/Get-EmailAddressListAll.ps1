Function Get-EmailAddressListAll
{
    [cmdletbinding()]
    param(
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$date_added,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$last_modified,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$include_inactive,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$sort_token,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$constituent_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$limit,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$offset
    )
    Begin{
        # Get necessary items from config file
        $config = Get-Content ".\config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/emailaddresses'
        $endUrl = ''

        # Get the supplied parameters

        # Specify which params are treated differently by the API
        $arrayParms = 'constituent_id'

        # Define variable which can accept multiple instances of the same key and
        # build a hash of the parameters
        $parms = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        foreach ($par in $PSBoundParameters.GetEnumerator())
        {
            # If the parameter is an array type, it can be provided multiple
            # times in the URL, so add each one as a new key/value pair
            if ($par.Key -in $arrayParms)
            {
                foreach ($val in $($par.Value))
                {
                    $parms.Add($par.Key,$val)
                }
            }
            # Otherwise add a new key value pair as normal
            else
            {
                $parms.Add($par.Key,$par.Value)
            }
        }

        # If the user supplied a limit, then respect it and don't get subsequent pages
        if ($null -ne $limit -and $limit -ne '') {$limit_supplied = $true}

        # Otherwise, grab them all
        if ($null -eq $limit -or $limit -eq '') {$limit = 5000}
        if ($null -eq $offset -or $offset -eq '') {$offset = 0}

        $parms.Remove('limit') | Out-Null
        $parms.Remove('offset') | Out-Null

        $parms.Add('limit',$limit)
        $parms.Add('offset',$offset)
    }

    Process{
            $res = Get-PagedEntityRENXT '' $endpoint $endUrl $api_subscription_key $myAuth $parms $limit_supplied
    }
    End{
        $res
    }
}
