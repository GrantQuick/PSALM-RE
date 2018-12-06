Function Get-CommunicationPreferenceListSingle
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

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/constituents/'
        $endUrl = '/communicationpreferences'

        # Get the supplied parameters
        $parms = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        foreach ($par in $PSBoundParameters.GetEnumerator())
        {
            $parms.Add($par.Key,$par.Value)
        }

        $parms.Remove('constituent_id') | Out-Null

    }

    Process{
        # Get data for one or more IDs
        $constituent_id | ForEach-Object {
            $res = Get-PagedApiResults $_ $endpoint $endUrl $api_subscription_key $myAuth $parms $limit
            $res
        }
    }
    End{
    }
}
