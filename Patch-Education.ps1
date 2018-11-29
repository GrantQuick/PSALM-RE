Function Patch-Education
{
    [cmdletbinding()]
    param(
        [parameter(
            #Position=0,
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$ID,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Campus,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Class_Of,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Class_Of_Degree,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Degree,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Department,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Faculty,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Known_Name,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Registration_Number,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$School,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Social_Organization,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Status,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Subject_Of_Study,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$Type
    )
    Begin{ 
        
        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir
        
        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        Function Patch-Education
        {
            [CmdletBinding()]
            param($uid, $updateProperties)

            $startUrl = 'https://api.sky.blackbaud.com/constituent/v1/educations/'

            $fullUri = $startUrl + $uid

            $apiCallResult =
            Invoke-RestMethod   -Method Patch `
                                -ContentType application/json `
                                -Headers @{
                                        'Authorization' = ("Bearer "+ $($myAuth.access_token))
                                        'bb-api-subscription-key' = ($api_subscription_key)} `
                                -Uri $fullUri `
                                -Body $updateProperties
            $apiCallResult
        }
        
        # Create JSON for supplied parameters
        $parms = $PSBoundParameters
        $parms.Remove('ID') | Out-Null
        $parmsJson = $parms | ConvertTo-Json
        
    }
    
    Process{ 
        # Update multiple IDs with the same data
        $i = 0
        $ID | ForEach-Object {
            $i++
            Write-Host "Patching Education ID $_ (record $i of $($ID.Length))"
            Patch-Education $_ $parmsJson | Out-Null
        }
    }
    End{}
}
