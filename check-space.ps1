# check if available space for files (bytes)

param(
    [string[]] $folderPathsInServer,
    [string] $accessToken
)

$authHeader = @{
'Authorization' = "Bearer $($accessToken)"
} 

$uri = "https://graph.microsoft.com/v1.0/me/drive/";
$driverIdResp = Invoke-WebRequest -Headers $authHeader -Uri $uri
$remainingSpace = ( $driverIdResp | ConvertFrom-Json ).quota.remaining #bytes

$uploadingFiles = @{} #full path in dev (key) / full path in one drive
$uploadingFilesSize = 0;



foreach ($folderPath in $folderPathsInServer){
    Write-Host "================="
    Write-Host "check space"
    Write-Host "$folderPath"
    $fileNameMap = .\get-all-file-names.ps1 $folderPath # file name (key) / full path in dev (value)
    Write-Host "filenameMap"
    Write-Host "$fileNameMap"
    foreach ($fileName in $fileNameMap.Keys){
        $oneDrivePath = .\get-one-drive-file-path.ps1 $fileName
        $isExist = .\check-file-exist.ps1 $oneDrivePath $accessToken

        if ($isExist){
            continue
        }

        $uploadingFiles[$fileNameMap[$fileName]] = $oneDrivePath
        $fileSize = (Get-Item $fileNameMap[$fileName]).Length
        $uploadingFilesSize += $fileSize
    }
}

if (($remainingSpace - 1000000000) -lt $uploadingFilesSize){
    # 1GB
    return @($false, $uploadingFiles)
}

@($true, $uploadingFiles)