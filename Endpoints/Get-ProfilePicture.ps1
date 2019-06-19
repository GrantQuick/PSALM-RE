Function Get-ProfilePicture
{
    [cmdletbinding()]
    param(
        [parameter(
            #Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][int[]]$constituent_id,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][boolean]$view_image,
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string]$download_folder
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
        $endUrl = '/profilepicture'
        
    }

    Process{
        # Get data for one or more IDs
        $constituent_id | ForEach-Object {
            $res = Get-UnpagedEntityRENXT $_ $endpoint $endUrl $api_subscription_key $myAuth $null
            $res

            # Open the image in a browser
            if ($view_image)
            {
                Start-Process $res.url
            }

            if ($download_folder -ne '')
            {
                # Download the file
                if (Test-Path $download_folder)
                {
                    $trimStart = Split-Path $imgUrl -leaf
                    $outputFileName = ($trimStart).Substring(0,$trimStart.IndexOf("?",0))
                    $output_location = Join-Path -Path $download_folder -ChildPath $outputFileName
                    Invoke-WebRequest $res.url -OutFile $output_location
                }
                else 
                {
                    write-host "Cannot download file to specified folder"
                }
            }
        }
    }
    End{
    }
}
