$token_uri = "https://oauth2.sky.blackbaud.com/token"

Function Get-SkyApiAuthTokenRENXT
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

Function Get-RefreshTokenRENXT
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

Function Show-OAuthWindowRENXT
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

Function Merge-SkyApiDateParmRENXT
{
    # Refactor the fuzzy date fields
    [CmdletBinding()]
    param($sourceHash, $dateField)
    $datePart = @{}

    $dayPart = $dateField + '_d'
    $monthPart = $dateField + '_m'
    $yearPart = $dateField + '_y'

    if ($sourceHash.ContainsKey($dayPart))
    {
        $datePart.Add('d',$sourceHash.$dayPart)
        $sourceHash.Remove($dayPart) | Out-Null
    }

    if ($sourceHash.ContainsKey($monthPart))
    {
        $datePart.Add('m',$sourceHash.$monthPart)
        $sourceHash.Remove($monthPart) | Out-Null
    }

    if ($sourceHash.ContainsKey($yearPart))
    {
        $datePart.Add('y',$sourceHash.$yearPart)
        $sourceHash.Remove($yearPart) | Out-Null
    }

    if ($datePart.Count -gt 0)
    {
        $sourceHash.Add($dateField,$datePart)
    }

    $sourceHash
}

Function Convert-SkyApiDateParmRENXT
{
    # Refactor the fuzzy date fields
    [CmdletBinding()]
    param($sourceHash, $dateField)

    if ($sourceHash.ContainsKey($dateField))
    {
        $sourceHash.$dateField = Get-Date $sourceHash.$dateField -Format "s"
    }

    $sourceHash
}

Function Update-SkyApiEntityRENXT
{
    [CmdletBinding()]
    param($uid, $updateProperties, $url, $endUrl, $api_key, $authorisation)

    $fullUri = $url + $uid + $endUrl

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

Function New-SkyApiEntityRENXT
{
    [CmdletBinding()]
    param($url, $addProperties, $api_key, $authorisation)

    $apiCallResult =
    Invoke-RestMethod   -Method Post `
                        -ContentType application/json `
                        -Headers @{
                                'Authorization' = ("Bearer "+ $($authorisation.access_token))
                                'bb-api-subscription-key' = ($api_key)} `
                        -Uri $url `
                        -Body $addProperties
    $apiCallResult
}

Function Remove-SkyApiEntityRENXT
{
    [CmdletBinding()]
    param($uid, $url, $endUrl, $api_key, $authorisation)

    $fullUri = $url + $uid + $endUrl

    $apiCallResult =
    Invoke-RestMethod   -Method Delete `
                        -ContentType application/json `
                        -Headers @{
                                'Authorization' = ("Bearer "+ $($authorisation.access_token))
                                'bb-api-subscription-key' = ($api_key)} `
                        -Uri $fullUri
    $apiCallResult
}

Function Get-UnpagedEntityRENXT
{
    [CmdletBinding()]
    param($uid, $url, $endUrl, $api_key, $authorisation, $params)

    $fullUri = $url + $uid + $endUrl
    $Request = [System.UriBuilder]$fullUri
    
    if ($null -ne $params -and $params -ne '') {
        $Request.Query = $params.ToString()
    }
    
    $apiCallResult =
    Invoke-RestMethod   -Method Get `
                        -ContentType application/json `
                        -Headers @{
                                'Authorization' = ("Bearer "+ $($authorisation.access_token))
                                'bb-api-subscription-key' = ($api_key)} `
                        -Uri $($Request.Uri.AbsoluteUri)
    $apiCallResult
}

Function Get-PagedEntityRENXT
{
    [CmdletBinding()]
    param($uid, $url, $endUrl, $api_key, $authorisation, $params, $limit_supplied)

    $fullUri = $url + $uid + $endUrl
    $Request = [System.UriBuilder]$fullUri
    $Request.Query = $params.ToString()

    $allRecords = @()

    # Call to the API
    do {
        $apiItems =
        Invoke-RestMethod   -Method Get `
                            -ContentType application/json `
                            -Headers @{
                                    'Authorization' = ("Bearer "+ $authorisation.access_token)
                                    'bb-api-subscription-key' = ($api_key)} `
                            -Uri $($Request.Uri.AbsoluteUri)
        $allRecords += $apiItems.value
        $recordCount = $apiItems.count
        [int]$params['offset'] += [int]$params['limit']
        $Request.Query = $params.ToString()

        # If the user supplied a limit, then respect it and don't get subsequent pages
        if ($true -eq $limit_supplied) {return $allRecords}
    } while ([int]$recordCount -gt [int]$params['offset'])

    $allRecords
}


# Import the endpoints
$endpoints  = @(Get-ChildItem -Path $PSScriptRoot\Endpoints\*.ps1)

Foreach($endpoint in $endpoints)
{
    Write-Host "Importing $endpoint"
    Try
    {
        . $endpoint.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($endpoint.fullname): $_"
    }
}