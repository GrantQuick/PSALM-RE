Function Patch-Address
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
        ][string]$address_lines,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$city,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$country,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$county,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$do_not_mail,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$end,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$postal_code,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$preferred,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_end_d,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_end_m,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_end_y,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_start_d,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_start_m,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$seasonal_start_y,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$start,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$state,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$suburb,
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

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/addresses/'

        # Create JSON for supplied parameters
        $parms = $PSBoundParameters
        $parms.Remove('ID') | Out-Null

        # Refactor any fuzzy date fields
        $parms = Update-SkyApiDateParms $parms 'seasonal_end'
        $parms = Update-SkyApiDateParms $parms 'seasonal_start'
        
        # Reformat any supplied dateTime fields
        $parms = Update-DateField $parms 'end'
        $parms = Update-DateField $parms 'start'

        # Convert the parameter hash table to a JSON
        $parmsJson = $parms | ConvertTo-Json
        
    }

    Process{
        # Update one or more IDs with the same data
        $i = 0
        $ID | ForEach-Object {
            $i++
            Write-Host "Patching Address ID $_ (record $i of $($ID.Length))"
            Update-SkyApiEntity $_ $parmsJson $endpoint $api_subscription_key $myAuth | Out-Null
        }
    }
    End{}
}
