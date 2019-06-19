Function Update-Constituent
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
        ][int]$birthdate_d,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$birthdate_m,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$birthdate_y,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$deceased,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$deceased_date_d,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$deceased_date_m,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int]$deceased_date_y,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$first,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$former_name,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$gender,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$gives_anonymously,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$inactive,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$last,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$lookup_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$marital_status,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$middle,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$name,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$preferred_name,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$suffix,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$suffix_2,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$title,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$title_2
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
        $endUrl = ''

        # Create JSON for supplied parameters
        $parms = $PSBoundParameters
        $parms.Remove('constituent_id') | Out-Null

        # Refactor any fuzzy date fields
        $parms = Merge-SkyApiDateParmRENXT $parms 'birthdate'
        $parms = Merge-SkyApiDateParmRENXT $parms 'deceased_date'

        # Convert the parameter hash table to a JSON
        $parmsJson = $parms | ConvertTo-Json
    }

    Process{
        # Update one or more IDs with the same data
        $i = 0
        $constituent_id | ForEach-Object {
            $i++
            Write-Host "Patching Constituent ID $_ (record $i of $($constituent_id.Length))"
            Update-SkyApiEntityRENXT $_ $parmsJson $endpoint $endUrl $api_subscription_key $myAuth | Out-Null
        }
    }
    End{}
}
