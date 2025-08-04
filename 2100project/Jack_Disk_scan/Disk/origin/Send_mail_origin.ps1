
param($Report)
#$hostaddr="192.168.6.00"

#$ErrorActionPreference = 'Stop'
#Set-PSDebug -Trace 1


$server = "mail.pthg.gov.tw"
$port = 25

$plainUser = "office@pthg.gov.tw"
$plainPass = "BMWyou20250722%"

$username = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainUser))
$password = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainPass))


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
        #Write-Host $line

        if ($line -match '^\d{3}\s') { break }
    }
}


Read-MultiLineResponse $reader


$writer.WriteLine("EHLO test.local")
Read-MultiLineResponse $reader


$writer.WriteLine("AUTH LOGIN")
Read-MultiLineResponse $reader

$writer.WriteLine($username)
Read-MultiLineResponse $reader

$writer.WriteLine($password)
Read-MultiLineResponse $reader


$writer.WriteLine("MAIL FROM:<office@pthg.gov.tw>")
Read-MultiLineResponse $reader

$writer.WriteLine("RCPT TO:<pthgcenter@gmail.com>")
Read-MultiLineResponse $reader


$writer.WriteLine("DATA")
Read-MultiLineResponse $reader


$writer.WriteLine("From: office@pthg.gov.tw")
$writer.WriteLine("To: pthgcenter@gmail.com")
$writer.WriteLine("Subject:磁碟空間剩餘報告")
$writer.WriteLine("") 
#$writer.WriteLine("TEST")
$writer.WriteLine("$Report")
$writer.WriteLine(".")
Read-MultiLineResponse $reader

$writer.WriteLine("QUIT")
Read-MultiLineResponse $reader

$stream.Close()
$client.Close()

