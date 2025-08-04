# disk.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-FreeSummary {
    param(
        [string]$Computer,
        [string]$Alias
    )

    try {
        $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DriveType=3" -ErrorAction Stop |
            Select-Object DeviceID,
                @{Name='SizeGB';Expression={ "{0:F1}" -f ($_.Size/1GB) }},
                @{Name='UsedGB';Expression={ "{0:F1}" -f (($_.Size - $_.FreeSpace)/1GB) }},
                @{Name='UsedPct';Expression={ "{0:F1}" -f (($_.Size - $_.FreeSpace)/$_.Size*100) }}

        if (-not $disks) {
            return "$Alias($Computer)-本次剩餘空間 取得磁碟資料失敗"
        }

        $parts = $disks | ForEach-Object {
            $letter = $_.DeviceID.TrimEnd(':')
            "$letter：$($_.UsedGB)/$($_.SizeGB)/$($_.UsedPct)%"
        }

        return "$Alias($Computer)-本次剩餘空間 " + ($parts -join ', ')
    } catch {
        return "$Alias($Computer)-取資料失敗：$($_.Exception.Message)"
    }
}

# 呼叫範例（固定別名 AP1 對應 192.168.6.82）
#Get-FreeSummary -Computer "192.168.6.82" -Alias "AP1"

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

$Report = ""
foreach ($hostaddr in $hostaddrs) {
    $Report += Get-FreeSummary -Computer $hostaddr.IP -Alias $t.Alias
    $Report += "`r`n"  # 換行
}
$Report


	$otherPath = Join-Path $PSScriptRoot 'Send_mail_origin.ps1'  # 同目錄下的 Other.ps1

	if (-not (Test-Path $otherPath)) {
		    Write-Error "找不到腳本：$otherPath"
#		    exit 1
	}
	try {
		    # 用 & 執行並傳參，結果收在 $result
		    $result = & $otherPath -Report $Report -ErrorAction Stop
		    Write-Host "子腳本回傳：$result"
	}
	catch {
		    Write-Error "呼叫失敗：$_"
#		    exit 1
	}
