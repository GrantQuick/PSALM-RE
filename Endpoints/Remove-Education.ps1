Function Remove-Education
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$education_id
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/educations/'
        $endUrl = ''
        
    }

    Process{
        # Remove entity
        $i = 0
        $education_id | ForEach-Object {
            $i++
            Write-Host "Deleting Education ID $_ (record $i of $($education_id.Length))"
            Write-Host $education_id
            Remove-SkyApiEntity $_ $endpoint $endUrl $api_subscription_key $myAuth | Out-Null
            Write-Host "Deleted Education ID $_ "
        }
    }
    End{}
}
