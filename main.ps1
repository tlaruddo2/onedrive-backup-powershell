# OneDrive path 
# App > Year > Month > Type (Audit, Hangfire, Serilog, Simcom) 

# folder path in server
$folderPathsInServer = @(
    'C:\Users\ajung\Desktop\kukjin\pipeline\powershell-file-upload-onedrive\db-backup\test\1', #could be './Simcom Backup'
    'C:\Users\ajung\Desktop\kukjin\pipeline\powershell-file-upload-onedrive\db-backup\test\2'
)

# $refreshToken = .\get-refresh-toekn.ps1

$accessToken = .\get-access-token-by-refresh-token.ps1
$authHeader = @{
    'Authorization' = "Bearer $($accessToken)"
}

$result = .\check-space.ps1 $folderPathsInServer $accessToken
$isEnoughSpace = $result[0]
$uploadingFiles = $result[1]


if (!$isEnoughSpace){
    Write-Output "No Enough Sapce in Onedrive"
    # TODO: send meesage with full path in dev, currently reutrn full path in OneDrive
    .\send-message-google-chat.ps1 999 $uploadingFiles
    exit
}

$statusCode = 0;
$uploadingFilesFailed = @{}
$uploadingFilesSucceed = @{}
foreach ( $oneDrivePath in $uploadingFiles.Keys ){
    $statusCode = .\large-upload-with-refresh-token.ps1 $accessToken $oneDrivePath $($uploadingFiles[$oneDrivePath])

    # add error handling
    if ($statusCode -ne 200){
        $uploadingFilesFailed[$oneDrivePath] = $($uploadingFiles[$oneDrivePath])
    }

    if ($statusCode -eq 200){
        $uploadingFilesSucceed[$oneDrivePath] = $($uploadingFiles[$oneDrivePath])
    }
}

# upload again 
$uploadingFilesFailed2 = @{}
foreach ( $oneDrivePath in $uploadingFilesFailed.Keys ){
    $statusCode = .\large-upload-with-refresh-token.ps1 $accessToken $oneDrivePath $($uploadingFilesFailed[$oneDrivePath])

    # add error handling
    if ($statusCode -ne 200){
        $uploadingFilesFailed2[$oneDrivePath] = $($uploadingFilesFailed[$oneDrivePath])
    }

    if ($statusCode -eq 200){
        $uploadingFilesSucceed[$oneDrivePath] = $($uploadingFilesFailed[$oneDrivePath])
    }
}

if ($uploadingFilesFailed2.Count -gt 0) {
    .\send-message-google-chat.ps1 200 $uploadingFilesFailed2
    exit
}

if ($uploadingFiles -and $statusCode -eq 200){
    Write-Output "Back up is done"
    .\send-message-google-chat.ps1 200 $uploadingFilesSucceed
    exit
}