# upload large file using session, each session up to 60MB

param(
    [string] $accessToken,
    [string] $filepathInDev, #full path 
    [string] $filepathInOneDrive # full path
)

$authHeader = @{
'Authorization' = "Bearer $($accessToken)"
}

# get drivder id 
$uri = "https://graph.microsoft.com/v1.0/me/drive/"
$driverIdResp = Invoke-WebRequest -Headers $AuthHeader -Uri $uri
$driverId = ( $driverIdResp | ConvertFrom-Json ).id

# get folder id (root)
$uri = "https://graph.microsoft.com/v1.0/me/drive/root"
$folderIdResp = Invoke-WebRequest -Headers $AuthHeader -Uri $uri
$folderId = ( $folderIdResp | ConvertFrom-Json ).id

$fileStream = [System.IO.File]::OpenRead($filepathInDev)
$totalFileSize = [int64]$fileStream.Length
Write-Output $totalFileSize

$binaryReader = [System.IO.BinaryReader]::new($fileStream)


$uri = "https://graph.microsoft.com/v1.0/me/drive/items/$($folderId):/$($filepathInOneDrive):/createUploadSession"
$uploadUrlResp = Invoke-RestMethod -Uri $uri -Method POST -Headers $authHeader 
$uploadUrl = $uploadUrlResp.uploadUrl
$expirationDateTime = $uploadUrlResp.expirationDateTime

$chunkSize = [int64] 327680  # 320 KiB in bytes


$startPosition = 0
$endPosition = $startPosition + $chunkSize - 1

$authHeader = @{
    'Authorization' = "Bearer $($accessToken)"
    "Content-Length" = $contentLength
    "Content-Range" = $contentRange
}

# Loop through the file and read each chunk
while ($startPosition -lt $totalFileSize) {
    # Calculate the actual size of the chunk (last chunk might be smaller)
    $chunkSize = [Math]::Min($chunkSize, $totalFileSize - $startPosition)

    # Define the start and end positions for this chunk
    $startPositionString = $startPosition.ToString()
    $endPositionString = ($startPosition + $chunkSize - 1).ToString()
    $contentRange = "bytes $startPositionString-$endPositionString/$totalFileSize"

    # Define the authorization header for this chunk
    $authHeader = @{
        'Authorization' = "Bearer $accessToken"
        "Content-Length" = $chunkSize
        "Content-Range" = $contentRange
    }

    # Read the chunk of bytes
    $chunk = $binaryReader.ReadBytes($chunkSize)

    try {
        $resp = Invoke-RestMethod -Uri $uploadUrl -Method PUT -Headers $authHeader -Body $chunk -ContentType 'application/zip'
    } catch {
        if ($_.Exception.Response -ne $null -and $_.Exception.Response.StatusCode -ge 500 -and $_.Exception.Response.StatusCode -lt 600) {
            Write-Host "A 5xx error occurred (connection error). Please try again later."
            return $_.Exception.Response.StatusCode
        } elseif ($_.Exception.Response.StatusCode -eq '404') {
            Write-Host "The resource was not found. Please check the URL."
            return 404
        } elseif ($_.Exception.Response.StatusCode -eq '401') {
            Write-Host "Unauthorized access. Please check your authentication credentials."
            return 401
        } else {
            Write-Host "An error occurred with status code $($_.Exception.Response.StatusCode): $($_.Exception.Message)"
            return $_.Exception.Response.StatusCode
        }
    }

    $startPosition = $endPosition + 1
    $endPosition = $startPosition + $chunkSize - 1
}

$binaryReader.Close()
$fileStream.Close()

return 200