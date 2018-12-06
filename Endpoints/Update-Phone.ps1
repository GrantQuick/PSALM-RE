Function Update-Phone
{
    [cmdletbinding()]
    param(
        [parameter(
            #Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$ID,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$do_not_call,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$inactive,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$number,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$primary,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$type
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/phones/'
        $endUrl = ''

        # Create JSON for supplied parameters
        $parms = $PSBoundParameters
        $parms.Remove('ID') | Out-Null

        # Convert the parameter hash table to a JSON
        $parmsJson = $parms | ConvertTo-Json
    }

    Process{
        # Update one or more IDs with the same data
        $i = 0
        $ID | ForEach-Object {
            $i++
            Write-Host "Patching Phone ID $_ (record $i of $($ID.Length))"
            Update-SkyApiEntity $_ $parmsJson $endpoint $endUrl $api_subscription_key $myAuth | Out-Null
        }
    }
    End{}
}
