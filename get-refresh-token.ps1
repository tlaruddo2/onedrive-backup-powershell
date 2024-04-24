# STEP 1, get code to authorize
# https://login.live.com/oauth20_authorize.srf?client_id=de956604-8b43-4ab8-8dd6-8922df788d37&scope=files.readwrite.all%20offline_access&response_type=code&redirect_uri=https://login.live.com/oauth20_desktop.srf

# STEP1 RESULT 
# https://login.live.com/oauth20_desktop.srf?code=M.C519_SN1.2.U.93ac3ce1-68e3-7aab-2211-f064e765a034&lc=1033

# ===================================================
# Define the base URL without query parameters
# $baseUrl = 'https://login.live.com/oauth20_authorize.srf'

# # Define additional query parameters
# $queryParams = @{
#     'client_id' = 'de956604-8b43-4ab8-8dd6-8922df788d37'
#     'scope' = 'files.readwrite.all offline_access'
#     'response_type' = 'code'
#     'redirect_uri' = 'https://login.live.com/oauth20_desktop.srf'
# }

# # Constructing the URL with query parameters
# $queryString = $queryParams.GetEnumerator() | ForEach-Object { $_.Key + '=' + $_.Value }
# $fullUrl = $baseUrl + '?' + $queryString

# # Make the request
# $Results = Invoke-WebRequest -Method Get -Uri $fullUrl -MaximumRedirection 0 -ErrorAction SilentlyContinue
# Write-Host $Results.StatusCode
# # Check if the response is a redirection (status code 302)
# if ($Results.StatusCode -eq 302) 
# {
#      Write-Host $Results.Headers.Location 
# } 

# ==========================================================


# Step 2 , get access token and refreser token
$code = 'M.C519_SN1.2.U.8fa5aacb-a9df-6e44-6190-f50b3a5ecdd2'
$url = "https://login.live.com/oauth20_token.srf"
$client_id = "de956604-8b43-4ab8-8dd6-8922df788d37"
$client_secret = "SYg8Q~IoCsXJLGS5h9O.SD.HJyHjYy40twX1ucoT"
$redirect_uri = "https://login.live.com/oauth20_desktop.srf"

$body = @{
    client_id = $client_id
    redirect_uri = $redirect_uri    
    code = $code
    grant_type = "authorization_code"
}

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}

$response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers

Write-Output $response
