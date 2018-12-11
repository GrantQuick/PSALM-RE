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
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
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
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        foreach ($par in $PSBoundParameters.GetEnumerator())
        {
            # If the parameter is an array type, it can be provided multiple
            # times in the URL, so add each one as a new key/value pair
            if ($par.Key -in $arrayParms)
            {
                foreach ($val in $($par.Value))
                {
                    $Parameters.Add($par.Key,$val)
                }
            }
            # Otherwise add a new key value pair as normal
            else
            {
                $Parameters.Add($par.Key,$par.Value)
            }
        }

        $Parameters.Remove('constituent_id')        

    }

    Process{
        # Get data for one or more IDs
        $constituent_id | ForEach-Object {
            $res = Get-PagedApiResults $_ $endpoint $endUrl $api_subscription_key $myAuth $Parameters $limit
            $res
        }
    }
    End{
    }
}
