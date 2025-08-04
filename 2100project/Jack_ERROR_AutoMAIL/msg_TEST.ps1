$hostaddrs=@("192.168.6.88","192.168.6.89","192.168.6.90","192.168.6.91","192.168.6.92","192.168.6.68","192.168.6.69","192.168.6.70","192.168.6.71","192.168.6.72","192.168.6.118","192.168.6.119","192.168.6.120","192.168.6.121","192.168.6.122")

foreach ($hostaddr in $hostaddrs) {


#$PSScriptRoot="C:\Users\2100admin\Desktop\ERROR_MAIL"
$WatchFolder="\\$($hostaddr)\c$\2100\SAVE\ERROR"
$Threshold =5 

cmdkey /add:$hostaddr /user:tech2100 /pass:!QAZ2wsx
net use \\$hostaddr\c$ /persistent:no


$fileCount = (Get-ChildItem -Path $WatchFolder | Measure-Object).Count
if (-not (Test-Path $WatchFolder)) {
    Write-Error "Folder doesn't exist：$WatchFolder"
	EXIT 1
}
ELSEif ($fileCount -le $Threshold) {
	Write-Host "Test-Path $WatchFolder"
	Test-Path $WatchFolder
	Write-Host "filecount $fileCount not> $Threshold Don't send"
#	Read-Host -Prompt 'Press Enter to the end'
#	EXIT 0
}
ELSE{
	Write-Host "Test-Path $WatchFolder"
	Test-Path $WatchFolder
	Write-Host "filecount  $fileCount > $Threshold send"

	$otherPath = Join-Path $PSScriptRoot 'Send_mail.ps1'  # 同目錄下的 Other.ps1

	if (-not (Test-Path $otherPath)) {
		    Write-Error "找不到腳本：$otherPath"
#		    exit 1
	}
	try {
		    # 用 & 執行並傳參，結果收在 $result
		    $result = & $otherPath -hostaddr $hostaddr -filecount $filecount -WatchFolder $WatchFolder -ErrorAction Stop
		    Write-Host "子腳本回傳：$result"
	}
	catch {
		    Write-Error "呼叫失敗：$_"
#		    exit 1
	}

	Write-Host "success"
}



net use \\$hostaddr\c$ /delete
cmdkey /delete:$hostaddr

}

#Read-Host -Prompt 'Press Enter to the end'


