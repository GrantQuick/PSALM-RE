Function Update-CommunicationPreference
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$communication_preference_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$end,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$solicit_code,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$start
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/communicationpreferences/'
        $endUrl = ''

        # Create JSON for supplied parameters
        $parms = $PSBoundParameters
        $parms.Remove('communication_preference_id') | Out-Null

        # Reformat any supplied dateTime fields
        $parms = Convert-SkyApiDateParmRENXT $parms 'end'
        $parms = Convert-SkyApiDateParmRENXT $parms 'start'

        # Convert the parameter hash table to a JSON
        $parmsJson = $parms | ConvertTo-Json
    }

    Process{
        # Update one or more IDs with the same data
        $i = 0
        $communication_preference_id | ForEach-Object {
            $i++
            Write-Host "Patching Communication Preference ID $_ (record $i of $($communication_preference_id.Length))"
            Update-SkyApiEntityRENXT $_ $parmsJson $endpoint $endUrl $api_subscription_key $myAuth | Out-Null
        }
    }
    End{}
}
