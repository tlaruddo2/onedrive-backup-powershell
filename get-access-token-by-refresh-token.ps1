$url = "https://login.live.com/oauth20_token.srf"
$clientId = "de956604-8b43-4ab8-8dd6-8922df788d37" # will be replaced
$clientSecret = "f1q8Q~YaQGDFuhUUTGOLjJK3qO1fOBekYHpd2bue"  # will be replaced
$redirectUri = "https://login.live.com/oauth20_desktop.srf"

$refreshTokenFilePath = "./refresh-token.txt"
$refreshToken = Get-Content -Path $refreshTokenFilePath

$body = @{
    client_id = $clientId
    redirect_uri = $redirectUri    
    refresh_token = $refreshToken
    grant_type = "refresh_token"
}

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}

$accessTokenResp = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
$refreshToken = $accessTokenResp.refresh_token 
$accessToken = $accessTokenResp.access_token

$refreshTokenFilePath = "refresh-token.txt"
$refreshToken | Out-File -FilePath $refreshTokenFilePath -Encoding ascii -Force

$accessToken