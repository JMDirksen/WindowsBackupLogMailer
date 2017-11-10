. "$PSScriptRoot\EmailCredentials.ps1"

# Get Backupset
$backupSet = "Files:`n"
(Get-WBPolicy).FilesSpecsToBackup | ForEach-Object {
    $backupSet += $_.FilePath + $_.FileName + "`n"
}
$backupSet += "VMs:`n"
(Get-WBPolicy).ComponentsToBackup | ForEach-Object {
    $backupSet += $_.VMName + "`n"
}

# Get Logs
$logs = Get-WinEvent Microsoft-Windows-Backup |
Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-1) } |
Select-Object TimeCreated, Message |
Sort-Object TimeCreated |
Out-String

# Setup E-mail body
$body = "BackupSet:`n" + $backupSet + $logs

# Send E-mail
$EmailFrom = $Email
$EmailTo = $Email
$msg = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$msg.Subject = "WindowsBackupLog"
$msg.Body = $body
$SMTPServer = "smtp.gmail.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Email, $Password);
$SMTPClient.Send($msg)
