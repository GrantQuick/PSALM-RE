Function Get-ConstituentFromLookup
{
    [cmdletbinding()]
    param(
        [parameter(
            #Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$search_text,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$include_inactive = 0
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/constituents/search?search_text='
        $endUrl = '&include_inactive=' + $include_inactive
        $endUrl = $endUrl + '&search_field=lookup_id'
    }

    Process{
        # Get data for one or more IDs
        $outputArray = @()
        $i = 0
        $search_text | ForEach-Object {
            $i++
            $res = Get-SkyApiEntity $_ $endpoint $endUrl $api_subscription_key $myAuth
            $outputArray += $res.value
        }
    }
    End{
        $outputArray
    }
}
