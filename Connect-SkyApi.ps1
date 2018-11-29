Function Connect-SkyApi {
    [CmdletBinding()]
    param([Switch]$force)
    
    Import-Module 'SkyApi' -Force

    # Database Parameters
    $authorize_uri = "https://oauth2.sky.blackbaud.com/authorization"
    $redirect_uri = "http://localhost/5000"

    $config = Get-Content ".\Config.json" | ConvertFrom-Json
    $key_dir = ($config | Select-Object -Property "key_dir").key_dir
    $client_id = ($config | Select-Object -Property "client_id").client_id
    $client_secret = ($config | Select-Object -Property "client_secret").client_secret

    [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null

    # Build authorisation URI
    $strUri = $authorize_uri +
        "?client_id=$client_id" +
        "&redirect_uri=" + [System.Web.HttpUtility]::UrlEncode($redirect_uri) +
        '&response_type=code&state=state'

    Function Get-NewToken
    {
        [CmdletBinding()]
        param($fileLocation)
    
        $authOutput = Show-OAuthWindow -URL $strUri
    
        # Get auth token
        $Authorization = Get-SkyApiAuthToken 'authorization_code' $client_id $redirect_uri $client_secret $authOutput["code"]
        
        # Swap token for a refresh token
        $Authorization = Get-RefreshToken 'refresh_token' $client_id $redirect_uri $client_secret $authorization.refresh_token
    
        # Save credentials to file
        $Authorization | Select-Object access_token, refresh_token | ConvertTo-Json | Out-File -FilePath $fileLocation -Force
        
    }
    
    # If key file does not exist
    if ((-not (Test-Path $key_dir)) -or ($force))
    {
        Get-NewToken $key_dir
    }
    
    # Check if refresh token is nearing expiry, and if so get a new one
    $lastWrite = (get-item $key_dir).LastWriteTime
    $minTimespan = new-timespan -days 30
    $maxTimespan = new-timespan -days 60
    
    # Token is older than 30 days and but younger than 60
    if ((((get-date) - $lastWrite) -gt $minTimespan) -and (((get-date) - $lastWrite) -lt $maxTimespan))  {
        Write-Host "older"
        $myAuth = Get-Content $key_dir | ConvertFrom-Json
        $Authorization = Get-RefreshToken 'refresh_token' $client_id $redirect_uri $client_secret $($myAuth.refresh_token)
        $Authorization | Select-Object access_token, refresh_token | ConvertTo-Json | Out-File -FilePath $key_dir -Force
    } 
    
    # If token has expired
    if (((get-date) - $lastWrite) -gt $maxTimespan) {
        Get-NewToken $key_dir
    }
}



