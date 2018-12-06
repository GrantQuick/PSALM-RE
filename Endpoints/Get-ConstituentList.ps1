Function Get-ConstituentList
{
    [cmdletbinding()]
    param(
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$constituent_code,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$constituent_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$custom_field_category,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$fields,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$fundraiser_status,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$include_deceased,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$include_inactive,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$postal_code,
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
        ][string]$sort_token,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$sort,
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
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/constituents'
        $endUrl = ''

        # Get the supplied parameters

        # Specify which params are treated differently by the API
        $arrayParms = 'constituent_code','constituent_id','custom_field_category'
        $listParms = 'fields','fundraiser_status','postal_code','sort'

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
            # If the parameter is a list type, multiple values will be
            # provided as a single string of comma separated values against
            # a single instance of the key
            elseif ($par.Key -in $listParms)
            {
                $listString = ''
                foreach ($l in $($par.Value))
                {
                    $listString += $l + ','
                }
                # Remove final comma
                $listString = $listString -replace ".$"
                $Parameters.Add($par.Key,$listString)
            }
            # Otherwise add a new key value pair as normal
            else
            {
                $Parameters.Add($par.Key,$par.Value)
            }
        }
    }

    Process{
            $res = Get-PagedApiResults '' $endpoint $endUrl $api_subscription_key $myAuth $Parameters $limit
    }
    End{
        $res
    }
}
