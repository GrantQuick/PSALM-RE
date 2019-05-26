Function Remove-ConstituentConsent
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$consent_id
    )
    Begin{
        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/commpref/v1/consents/'
        $endUrl = ''
  

    }

    Process{
        # Remove record for one or more IDs
        $i = 0
        $consent_id | ForEach-Object {
            $i++
            Write-Host "Deleting Consent ID $_ (record $i of $($consent_id.Length))"
            Write-Host $consent_id
            Remove-SkyApiEntity $_ $endpoint $endUrl $api_subscription_key $myAuth | Out-Null
            Write-Host "Deleted Consent ID $_ "
        }
    }
    End{
    }
}
