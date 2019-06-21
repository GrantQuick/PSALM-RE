Function Get-ConstituentConsentList
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$constituent_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$most_recent_only,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$limit,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$skip,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$channels,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$categories
    )
    Begin{
        # Get necessary items from config file
        $config = Get-Content ".\config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/commpref/v1/constituents/'
        $endUrl = '/consents'

        # Specify which params are treated differently by the API
        $arrayParms = 'channels','categories'

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

        $parms.Remove('constituent_id')  
        
        # If the user supplied a limit, then respect it and don't get subsequent pages
        if ($null -ne $limit -and $limit -ne '') {$limit_supplied = $true}

        # Otherwise, grab them all
        if ($null -eq $limit -or $limit -eq '') {$limit = 500}
        if ($null -eq $offset -or $offset -eq '') {$offset = 0}

        $parms.Remove('limit') | Out-Null
        $parms.Remove('offset') | Out-Null

        $parms.Add('limit',$limit)
        $parms.Add('offset',$offset)

    }

    Process{
        # Get data for one or more IDs
        $constituent_id | ForEach-Object {
            $res = Get-PagedEntityRENXT $_ $endpoint $endUrl $api_subscription_key $myAuth $parms $limit_supplied
            $res | Add-Member -NotePropertyName constituent_id -NotePropertyValue $_
            $res
        }
    }
    End{
    }
}
