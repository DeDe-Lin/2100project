#$plainPass = "BMWyou20250722%"

param($Report)

$server = "mail.pthg.gov.tw"
$port = 25

$plainUser = "office@pthg.gov.tw"
$plainPass = "BMWyou20250722%"

# 編碼 credentials
$username = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainUser))
$password = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainPass))

# 準備 HTML body（假設 $Report 已經是 HTML 片段，若不是可以把純文字轉成簡單 HTML）
$bodyHtml = @"
<html>
  <body>
    <h3 style="margin-bottom:0;">磁碟剩餘空間報告</h3>
    <pre style="font-family: Consolas, monospace;">$Report</pre>
  </body>
</html>
"@

# 將 body 用 UTF8 轉 bytes 再 base64
$bodyBytes = [Text.Encoding]::UTF8.GetBytes($bodyHtml)
$bodyBase64 = [Convert]::ToBase64String($bodyBytes)

# 將 base64 換成每行不超過 76 字元（SMTP 規範）
$wrappedBody = ($bodyBase64 -split "(.{1,76})" | Where-Object { $_ -ne "" }) -join "`r`n"

# 對 Subject 做 RFC2047 base64 編碼（中文）
$subjectText = "磁碟空間剩餘報告"
$subjectB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($subjectText))
$encodedSubject = "=?UTF-8?B?56OB56Kf56m66ZaT5Ymp6aSY5aCx5ZGK?="

# 建連線
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($server, $port)
$stream = $client.GetStream()

$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

function Read-MultiLineResponse {
    param($reader)
    while ($true) {
        $line = $reader.ReadLine()
        if ($null -eq $line) { break }
        # 你可以解除下面註解來 debug SMTP 回應
        # Write-Host "S: $line"
        if ($line -match '^\d{3}\s') { break }
    }
}

# 讀迎接訊息
Read-MultiLineResponse $reader

# EHLO
$writer.WriteLine("EHLO test.local")
Read-MultiLineResponse $reader

# AUTH LOGIN
$writer.WriteLine("AUTH LOGIN")
Read-MultiLineResponse $reader

$writer.WriteLine($username)
Read-MultiLineResponse $reader

$writer.WriteLine($password)
Read-MultiLineResponse $reader

# FROM / TO
$writer.WriteLine("MAIL FROM:<office@pthg.gov.tw>")
Read-MultiLineResponse $reader

$writer.WriteLine("RCPT TO:<pthgcenter@gmail.com>")
Read-MultiLineResponse $reader

# DATA 開始
$writer.WriteLine("DATA")
Read-MultiLineResponse $reader

# 寫 header（注意用 CRLF，自動用 WriteLine 會加）
$writer.WriteLine("From: office@pthg.gov.tw")
$writer.WriteLine("To: pthgcenter@gmail.com")
$writer.WriteLine("Subject: $encodedSubject")
$writer.WriteLine("MIME-Version: 1.0")
$writer.WriteLine('Content-Type: text/html; charset="utf-8"')
$writer.WriteLine("Content-Transfer-Encoding: base64")
$writer.WriteLine("")  # header 與 body 之間空行

# 寫 body（已經包成 base64 並換行）
foreach ($line in $wrappedBody -split "`r`n") {
    # 如果一行以點開頭要加一個點（dot-stuffing）
    if ($line.StartsWith(".")) {
        $writer.WriteLine(".$line")
    } else {
        $writer.WriteLine($line)
    }
}

# 終止 DATA 段：單獨一行點
$writer.WriteLine(".")
Read-MultiLineResponse $reader

# QUIT
$writer.WriteLine("QUIT")
Read-MultiLineResponse $reader

$stream.Close()
$client.Close()

