Function Get-EducationSubjects
{
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/educations/subjects'
        $endUrl = ''

        $obj_list = @()

    }

    Process{
        # Get data
        $data = Get-SkyApiEntity $_ $endpoint $endUrl $api_subscription_key $myAuth
        # Convert array to object list
        $obj_list = $data.value | Select-Object @{Name='subject';Expression={$_}}
              
    }
    End{
        $obj_list
    }
}
