# Generate the EmailCredentials file by running the following command:
# Get-Credential | Export-Clixml "EmailCredentials.xml"

# Get Backupset
$backupSet = " Files:`n"
(Get-WBPolicy).FilesSpecsToBackup | ForEach-Object {
    $backupSet += "  - " + $_.FilePath + $_.FileName + "`n"
}
$backupSet += " VMs:`n"
(Get-WBPolicy).ComponentsToBackup | ForEach-Object {
    $backupSet += "  - " + $_.VMName + "`n"
}

# Get Logs
$logs = Get-WinEvent Microsoft-Windows-Backup |
Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-1) } |
Select-Object TimeCreated, Message |
Sort-Object TimeCreated |
Format-Table -Wrap |
Out-String

# Setup E-mail body
$body = "<pre>BackupSet:`n" + $backupSet + $logs + "</pre>"

# Send E-mail
$credentials = Import-Clixml "EmailCredentials.xml"
$Email = @{
    "From"       = $credentials.UserName
    "To"         = $credentials.UserName
    "Subject"    = "[$env:COMPUTERNAME] WindowsBackupLogMailer"
    "Body"       = $body
    "BodyAsHtml" = $true
    "SmtpServer" = "smtp.gmail.com"
    "Port"       = 587
    "UseSsl"     = $true
    "Credential" = $credentials
}
Send-MailMessage @Email
