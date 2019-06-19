Function Get-ActionCustomFieldCategoryValues
{
    [cmdletbinding()]
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )
        ][string[]]$category_name
    )
    Begin{

        # Get necessary items from config file
        $config = Get-Content ".\Config.json" | ConvertFrom-Json
        $api_subscription_key = ($config | Select-Object -Property "api_subscription_key").api_subscription_key
        $key_dir = ($config | Select-Object -Property "key_dir").key_dir

        # Grab the keys
        $getSecureString = Get-Content $key_dir | ConvertTo-SecureString
        $myAuth = ((New-Object PSCredential "user",$getSecureString).GetNetworkCredential().Password) | ConvertFrom-Json

        $endpoint = 'https://api.sky.blackbaud.com/constituent/v1/actions/customfields/categories/values'
        $endUrl = ''
        
        # Get the supplied parameters
        $parms = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        foreach ($par in $PSBoundParameters.GetEnumerator())
        {
            $parms.Add($par.Key,$par.Value)
        }
        

    }

    Process{
        # Get data for one or more IDs 
        $category_name | ForEach-Object {
            $res = Get-UnpagedEntityRENXT '' $endpoint $endUrl $api_subscription_key $myAuth $parms
            $res.value
        }
    }
    End{
    }
}
