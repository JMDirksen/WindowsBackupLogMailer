. "$PSScriptRoot\EmailCredentials.ps1"

$logs = Get-WinEvent Microsoft-Windows-Backup |
Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-1) } |
Select-Object TimeCreated, Message |
Sort-Object TimeCreated

$EmailFrom = $Email
$EmailTo = $Email
$msg = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$msg.Subject = "WindowsBackupLog"
$msg.IsBodyHtml = $true
$msg.Body = $logs | ConvertTo-Html
$SMTPServer = "smtp.gmail.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Email, $Password);
$SMTPClient.Send($msg)
