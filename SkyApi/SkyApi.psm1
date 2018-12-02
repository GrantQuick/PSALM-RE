$token_uri = "https://oauth2.sky.blackbaud.com/token"

Function Get-SkyApiAuthToken
{
    [CmdletBinding()]
    param($grant_type,$client_id,$redirect_uri,$client_secret,$authCode)

    #Build token request
    $AuthorizationPostRequest = 'grant_type=' + $grant_type + '&' +
    'redirect_uri=' + [System.Web.HttpUtility]::UrlEncode($redirect_uri) + '&' +
    'client_id=' + $client_id + '&' +
    'client_secret=' + [System.Web.HttpUtility]::UrlEncode($client_secret) + '&' +
    'code=' + $authCode

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Authorization =
        Invoke-RestMethod   -Method Post `
                            -ContentType application/x-www-form-urlencoded `
                            -Uri $token_uri `
                            -Body $AuthorizationPostRequest
    $Authorization
}

Function Get-RefreshToken
{
    [CmdletBinding()]
    param($grant_type,$client_id,$redirect_uri,$client_secret,$authCode)

    #Build token request
    $AuthorizationPostRequest = 'grant_type=' + $grant_type + '&' +
    'redirect_uri=' + [System.Web.HttpUtility]::UrlEncode($redirect_uri) + '&' +
    'client_id=' + $client_id + '&' +
    'client_secret=' + [System.Web.HttpUtility]::UrlEncode($client_secret) + '&' +
    'refresh_token=' + $authCode

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Authorization =
        Invoke-RestMethod   -Method Post `
                            -ContentType application/x-www-form-urlencoded `
                            -Uri $token_uri `
                            -Body $AuthorizationPostRequest
    $Authorization
}

Function Show-OAuthWindow
{
    param(
        [System.Uri]$Url
    )

    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=440;Height=640}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=($url ) }
    $DocComp  = {
        $Global:uri = $web.Url.AbsoluteUri
        if ($Global:Uri -match "error=[^&]*|code=[^&]*") {$form.Close() }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null

    $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
    $output = @{}
    foreach($key in $queryOutput.Keys){
        $output["$key"] = $queryOutput[$key]
    }

    $output
}

Function Update-SkyApiDateParms
{
    # Refactor the fuzzy date fields
    [CmdletBinding()]
    param($dateHash, $dateField)
    $datePart = @{}

    $dayPart = $dateField + '_d'
    $monthPart = $dateField + '_m'
    $yearPart = $dateField + '_y'

    if ($dateHash.ContainsKey($dayPart))
    {
        $datePart.Add('d',$dateHash.$dayPart)
        $dateHash.Remove($dayPart) | Out-Null
    }

    if ($dateHash.ContainsKey($monthPart))
    {
        $datePart.Add('m',$dateHash.$monthPart)
        $dateHash.Remove($monthPart) | Out-Null
    }

    if ($dateHash.ContainsKey($yearPart))
    {
        $datePart.Add('y',$dateHash.$yearPart)
        $dateHash.Remove($yearPart) | Out-Null
    }

    if ($datePart.Count -gt 0)
    {
        $dateHash.Add($dateField,$datePart)
    }

    $dateHash
}

Function Update-SkyApiEntity
{
    [CmdletBinding()]
    param($uid, $updateProperties, $url, $api_key, $authorisation)

    $fullUri = $url + $uid

    $apiCallResult =
    Invoke-RestMethod   -Method Patch `
                        -ContentType application/json `
                        -Headers @{
                                'Authorization' = ("Bearer "+ $($authorisation.access_token))
                                'bb-api-subscription-key' = ($api_key)} `
                        -Uri $fullUri `
                        -Body $updateProperties
    $apiCallResult
}