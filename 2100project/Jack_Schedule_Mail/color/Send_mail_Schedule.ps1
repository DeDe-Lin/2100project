
param(
    [string]$outputHtml,
    [bool]$BodyAsHtml = $true
)

$outputHtml
#Read-Host -Prompt '按一下 Enter離開'

$server = "mail.pthg.gov.tw"
$port = 25

$username= "office@pthg.gov.tw"
$password = "BMWyou20250722%"

$securePwd = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePwd)

#  寄送郵件


$mailMessage = New-Object System.Net.Mail.MailMessage
$mailMessage.From = "office@pthg.gov.tw"
$mailMessage.To.Add("pthgcenter@gmail.com")
$mailMessage.Subject = "各工作站工作排程器執行報告"
$mailMessage.Body = $outputHtml
$mailMessage.IsBodyHtml = $BodyAsHtml
$mailMessage.BodyEncoding = [System.Text.Encoding]::UTF8
$mailMessage.SubjectEncoding = [System.Text.Encoding]::UTF8

$smtp = New-Object System.Net.Mail.SmtpClient($server, $port)
$smtp.EnableSsl = $true
$smtp.Credentials = $credential
$smtp.Send($mailMessage)


###########################
#另外的方法，但只能用ascII編碼發出去，不能發中文的
#Send-MailMessage `
#    -From "office@pthg.gov.tw" `
#    -To "pthgcenter@gmail.com" `
#    -Subject "各工作站工作排程器執行報告" `
#    -Body $outputHtml `
#    -BodyAsHtml:$BodyAsHtml `
#    -SmtpServer $server `
#    -Port $port `
#    -UseSsl `
#    -Credential $credential

