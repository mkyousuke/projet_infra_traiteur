
$source = "C:\inetpub\wwwroot"
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$destination = "C:\backups\backup_$date.zip"

Compress-Archive -Path $source -DestinationPath $destination
