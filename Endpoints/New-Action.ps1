Function New-Action
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$constituent_id,
        [parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$category,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$completed,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$completed_date,
        [parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][datetime]$date,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$description,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$direction,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$end_time,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$fundraisers,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$location,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$opportunity_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$outcome,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$priority,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$start_time,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$status,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$summary,
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

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/actions'

    }

    Process{
        $i = 0
        # Get data for one or more IDs
        $constituent_id | ForEach-Object {
            $i++
            Write-Host "Adding action to Constituent ID $_ (record $i of $($constituent_id.Length))"
            # Create JSON for supplied parameters
            $parms = $PSBoundParameters
            $parms.Remove('constituent_id') | Out-Null
            $parms.Add('constituent_id',$_) | Out-Null
            # Convert the parameter hash table to a JSON
            $parmsJson = $parms | ConvertTo-Json
            # $parmsJson
            $created_id = New-SkyApiEntityRENXT $endpoint $parmsJson $api_subscription_key $myAuth
            write-host "Created action ID $($created_id.id)"
        }
    }
    End{
    }
}
