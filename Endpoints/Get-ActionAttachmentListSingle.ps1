Function Get-ActionAttachmentListSingle
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$action_id
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/actions/'
        $endUrl = '/attachments'
    }

    Process{
        # Get data for one or more IDs
        $action_id | ForEach-Object {
            $res = Get-UnpagedEntityRENXT $_ $endpoint $endUrl $api_subscription_key $myAuth $null
            $res.value
        }
    }
    End{
    }
}
