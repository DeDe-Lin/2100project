# disk.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 閾值（百分比），超過這個用紅色標註
$threshold = 80

function Get-FreeSummaryHtml {
    param(
        [string]$Computer,
        [string]$Alias
    )
    try {
        $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DriveType=3" -ErrorAction Stop |
            Select-Object DeviceID,
                @{Name='SizeGB';Expression={ "{0:F1}" -f ($_.Size/1GB) }},
                @{Name='FreeGB';Expression={ "{0:F1}" -f ($_.FreeSpace/1GB) }},
                @{Name='UsedPct';Expression={ "{0:F1}" -f (($_.Size - $_.FreeSpace)/$_.Size*100) }}

        if (-not $disks) {
            return "<tr><td>$Alias($Computer)</td><td>取得磁碟資料失敗</td></tr>"
        }

        $driveParts = $disks | ForEach-Object {
            $letter = $_.DeviceID.TrimEnd(':')
            $free = $_.FreeGB
            $size = $_.SizeGB
            $pct = $_.UsedPct
            $pctDisplay = if ([double]$pct -ge $threshold) {
                "<span style='color:red;font-weight:bold;'>$pct`%</span>"
            } else {
                "$pct`%"
            }
            "$letter：$free/$size/$pctDisplay"
        }

        return "<tr><td>$Alias($Computer)</td><td>$($driveParts -join ', ')</td></tr>"
    } catch {
        return "<tr><td>$Alias($Computer)</td><td>取資料失敗：$($_.Exception.Message)</td></tr>"
    }
}


# 主機清單（IP 對應別名）
$hostaddrs = @(
    @{IP='192.168.6.81'; Alias='AP1'},
    @{IP='192.168.6.82'; Alias='AP2'},
    @{IP='192.168.6.83'; Alias='AP3'},
    @{IP='192.168.6.84'; Alias='RAT'},
    @{IP='192.168.6.85'; Alias='AT'},
    @{IP='192.168.6.86'; Alias='DB'},
    @{IP='192.168.6.111'; Alias='AP1'},
    @{IP='192.168.6.112'; Alias='AP2'},
    @{IP='192.168.6.113'; Alias='AP3'},
    @{IP='192.168.6.114'; Alias='RAT'},
    @{IP='192.168.6.115'; Alias='AT'},
    @{IP='192.168.6.116'; Alias='DB'},
    @{IP='192.168.6.61'; Alias='AP1'},
    @{IP='192.168.6.62'; Alias='AP2'},
    @{IP='192.168.6.63'; Alias='AP3'},
    @{IP='192.168.6.64'; Alias='RAT'},
    @{IP='192.168.6.65'; Alias='AT'},
    @{IP='192.168.6.66'; Alias='DB'}
)

# 建 HTML 報告
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$bodyBuilder = @()
$bodyBuilder += "<html><body>"
$bodyBuilder += "<h3>磁碟剩餘空間報告</h3>"
$bodyBuilder += "<p>產生時間：$now</p>"
$bodyBuilder += "<table border='1' cellpadding='4' cellspacing='0' style='border-collapse:collapse;'>"
$bodyBuilder += "<tr><th>主機</th><th>磁碟狀況(剩餘容量GB/總容量GB/已使用%數)</th></tr>"

foreach ($hostaddr in $hostaddrs) {
    $bodyBuilder += Get-FreeSummaryHtml -Computer $hostaddr.IP -Alias $hostaddr.Alias
}

$bodyBuilder += "</table>"
$bodyBuilder += "</body></html>"

$ReportHtml = $bodyBuilder -join "`n"
$ReportHtml

	$otherPath = Join-Path $PSScriptRoot 'Send_mail_COLOR.ps1'  # 同目錄下的 Other.ps1

	if (-not (Test-Path $otherPath)) {
		    Write-Error "找不到腳本：$otherPath"
#		    exit 1
	}
	try {
		    # 用 & 執行並傳參，結果收在 $result
		    $result = & $otherPath -Report $ReportHtml -ErrorAction Stop
		    Write-Host "子腳本回傳：$result"
	}
	catch {
		    Write-Error "呼叫失敗：$_"
#		    exit 1
	}
