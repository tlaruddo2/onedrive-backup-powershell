# (done)make file path for OneDrive based on file name 

param (
    [string]$fileName
)

# example: # AuditSandBox_FULL_04182022_000053.BAK
$pattern = '^(?<prefix>.+?)_(?<date>\d{8})_(?<time>\d{6})\.(?<extension>BAK)$'

# Match the filename against the pattern
if ($fileName -match $pattern) {
    $prefix = $Matches['prefix']
    $date = $Matches['date']

    $baseDirectory = switch ($prefix) {
        "AuditSandBox_FULL" { "Fuel Sandbox" }
        "SystemSandBox_FULL" { "Fuel Sandbox" }
        "SystemSandBoxHangfire_FULL" { "Fuel Sandbox" }
        "SystemSandBoxSerilogsDb_FULL" { "Fuel Sandbox" }
        "AuditSimCom_FULL" { "Fuel Production" }
        "SystemSimCom_FULL" { "Fuel Production" }
        "Hangfire_FULL" { "Fuel Production" }
        "SerilogsDb_FULL" { "Fuel Production" }
        "WaterHangfire_FULL" { "Water Production" }
        "WaterSerilogsDb_FULL" { "Water Production" }
        "AuditSimComWater_FULL" { "Water Production" }
        "WaterSimCom_FULL" { "Water Production" }
        "AuditSimComWaterSandBox_FULL" { "Water Sandbox" }
        "WaterSimcomSandBox_FULL" { "Water Sandbox" }
        "WaterSandBoxHangfire_FULL" { "Water Sandbox" }
        "WaterSandBoxSerilogsDb_FULL" { "Water Sandbox" }            
        Default { $null }
    }             
    
    # Extract year and month from the date
    $year = $date.Substring(4, 4)
    $month = $date.Substring(0, 2)
    
    # Convert numeric month to abbreviated month name
    $monthName = switch ($month) {
        "01" { "Jan" }
        "02" { "Feb" }
        "03" { "Mar" }
        "04" { "Apr" }
        "05" { "May" }
        "06" { "Jun" }
        "07" { "Jul" }
        "08" { "Aug" }
        "09" { "Sep" }
        "10" { "Oct" }
        "11" { "Nov" }
        "12" { "Dec" }
        Default { $null }
    }
    
    if ($monthName -eq $null) {
        Write-Output "Invalid month in file name: $fileName"
        return
    }
    
    $month = "$month-$monthName"
    
    $last = switch ($prefix) {
        "AuditSandBox_FULL" { "Audit" }
        "SystemSandBox_FULL" { "Simcom" }
        "SystemSandBoxHangfire_FULL" { "HangFile" }
        "SystemSandBoxSerilogsDb_FULL" { "Serilog" }
        "AuditSimCom_FULL" { "Audit" }
        "SystemSimCom_FULL" { "Simcom" }
        "Hangfire_FULL" { "HangFire" }
        "SerilogsDb_FULL" { "Serilog" }
        "WaterHangfire_FULL" { "HangFile" }
        "WaterSerilogsDb_FULL" { "Serilog" }
        "AuditSimComWater_FULL" { "Audit" }
        "WaterSimCom_FULL" { "Simcom" }
        "AuditSimComWaterSandBox_FULL" { "Audit" }
        "WaterSimcomSandBox_FULL" { "Simcom" }
        "WaterSandBoxHangfire_FULL" { "HangFire" }
        "WaterSandBoxSerilogsDb_FULL" { "Serilog" }            
        Default { $null }
    }         

    # Construct the path
    $path = "{0}\{1}\{2}\{3}\{4}" -f $baseDirectory, $year, $month, $last, $fileName
    
    # Output the path
    $path
}
else {
    $path = ""
}