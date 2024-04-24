# (done) get all file name and full path of all files in folder

param (
    [string]  $directoryPath
)

$filesMap = @{}
Get-ChildItem -Path $directoryPath -File | ForEach-Object {
    $filesMap[$_.Name] = $_.FullName
}

# {
#     [filename, full path]
# }
$filesMap