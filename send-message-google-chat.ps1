# send message
# properly sending but need to change content

param(
    [int32] $statusCode,
    [hashtable] $uplaodingFiles
)

$WEBHOOK_URL = "https://chat.googleapis.com/v1/spaces/AAAA9MZa8WU/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=BK65KKANq9Q_31lz7Hnrf9q9nZGB0Gie3k2PuUJ4550"
$LOG_URL = "www.google.ca" # need to revised 

$TITLE = switch ($statusCode) {
    200 { "Backup Succeeded" }
    500 { "Internal Server Error" }
    502 { "Bad GateWay" }
    503 { "Service Unabled" }
    504 { "Gateway Timeout" }  
    504 { "Gateway Timeout" }  
    999 { 'Backup Failed - OneDrive Error'}       
    Default { "Unknow status code: $statusCode" }
}  

$MESSAGE = switch ($statusCode) {
    200 { "Backup Succeeded" }
    500 { "Internal Server Error" }
    502 { "Bad GateWay" }
    503 { "Service Unabled" }
    504 { "Gateway Timeout" }          
    999 { 'No enough space'}
    Default { "Unknow status code: $statusCode" }
}  

if ($statusCode -eq 999 -and $uplaodingFiles){
    #failed
    foreach ($file in $uplaodingFiles.Keys){
        $MESSAGE += "`n - $($uplaodingFiles[$file])"
    }
}

if ($statusCode -ne 200 -and $statusCode -ne 999 -and $uplaodingFiles){
    #failed
    foreach ($file in $uplaodingFiles.Keys){
        $MESSAGE += "`n - $($uplaodingFiles[$file])"
    }
}

if ($statusCode -eq 200 -and $uplaodingFiles){
    foreach ($file in $uplaodingFiles.Keys){
        $MESSAGE += "`n - $($uplaodingFiles[$file])"
    }
}

$IMAGE_URL = switch ($statusCode) {
    200 { "https://cdn-icons-png.flaticon.com/128/190/190411.png" }
    500 { "https://cdn-icons-png.flaticon.com/512/6659/6659895.png" }
    502 { "https://cdn-icons-png.flaticon.com/512/6659/6659895.png" }
    503 { "https://cdn-icons-png.flaticon.com/512/6659/6659895.png" }
    504 { "https://cdn-icons-png.flaticon.com/512/6659/6659895.png" }
    999 { "https://cdn-icons-png.flaticon.com/512/6659/6659895.png" }
    Default { "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Icon-round-Question_mark.svg/1200px-Icon-round-Question_mark.svg.png" }
}  

$jsonBody = @{
    cards = @(
        @{
            header = @{
                title = $TITLE
                imageUrl = $IMAGE_URL
            }
            sections = @(
                @{
                    widgets = @(
                        @{
                            textParagraph = @{
                                text = $MESSAGE
                            }
                        }
                        ,
                        @{
                            buttons = @(
                                @{
                                    textButton = @{
                                        text = "View Log"
                                        onClick = @{
                                            openLink = @{
                                                url = $LOG_URL
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            )
        }
    )
}

$jsonString = $jsonBody | ConvertTo-Json -Depth 20
$jsonString

Invoke-RestMethod -Method Post -Uri $WEBHOOK_URL -ContentType "application/json" -Body $jsonString  
