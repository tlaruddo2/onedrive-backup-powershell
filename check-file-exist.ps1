# (done) check if file exist with path (folder and file both working)
# status code: 200(success), 404(not found)

param (
    [string] $path,
    [string] $accessToken
)

$authHeader = @{
'Authorization' = "Bearer $($accessToken)"
}

$uri = "https://graph.microsoft.com/v1.0/me/drive/root:/$path"
try {
    $resp = Invoke-WebRequest -Headers $authHeader -Uri $uri -ErrorAction Stop
    if ($resp.StatusCode -eq 200) {
        return $true
    }
}
catch {
    return $false;
}