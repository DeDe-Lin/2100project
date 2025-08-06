$hostaddrs=@("192.168.6.81","192.168.6.82","192.168.6.83","192.168.6.84","192.168.6.85","192.168.6.86","192.168.6.87","192.168.6.88","192.168.6.89","192.168.6.90","192.168.6.91","192.168.6.92","192.168.6.111","192.168.6.112","192.168.6.113","192.168.6.114","192.168.6.115","192.168.6.116","192.168.6.117","192.168.6.118","192.168.6.119","192.168.6.120","192.168.6.121","192.168.6.122","192.168.6.61","192.168.6.62","192.168.6.63","192.168.6.64","192.168.6.65","192.168.6.66","192.168.6.67","192.168.6.68","192.168.6.69","192.168.6.70","192.168.6.71","192.168.6.72")

#$hostaddrs=@("192.168.6.81","192.168.6.82","192.168.6.83")
$password = ConvertTo-SecureString '!QAZ2wsx'-AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('tech2100', $password )
$Alltasks=@()
$AllFailTasks=@()
foreach ($hostaddr in $hostaddrs) {
$result = Invoke-Command -ComputerName $hostaddr -Credential ($cred) -ArgumentList $hostaddr -ScriptBlock { 
    param($hostaddr)
    $tasks = @()
    $task = @()
    $failtasks = @()
    Get-ScheduledTask |
    Where-Object {
        $_.Author -like '*tech2100*' -or $_.Author -like '*2100admin*'
    } |

    ForEach-Object {
        $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath
        $resultMessage = switch ($info.LastTaskResult) {
            0          { '成功' }
            1          { '失敗：不明錯誤' }
            267009     { '任務已被使用者取消' }
            267011     { '任務已完成，但部分動作失敗' }
            267013     { '任務已被禁用' }
            2147750671 { '任務已完成，但有警告' }
            2147750687 { '工作排程服務無法啟動任務' }
            2147942402 { '找不到檔案或路徑錯誤' }
            2147942405 { '存取被拒' }
            2147943645 { '存取被拒 (Access is denied)' }
            2147943731 { '找不到指定的路徑' }
            2147943785 { '工作排程執行失敗，使用者帳戶錯誤' }
            Default    { "其他錯誤碼：$($_)" }
        }

        $task=[PSCustomObject]@{
            '主機IP'		= $hostaddr
            '排程名稱'		= $_.TaskName
            '狀態'		= $_.State
            '作者'		= $_.Author
            '最後一次執行時間'	= $info.LastRunTime
            '下次執行時間'	= $info.NextRunTime
            '最後執行結果'	= $resultMessage
        }
	$tasks+=$task
	  if ($info.LastTaskResult -ne 0) {
            $failtasks += $task
        }
    }
    return @{
        Tasks = $tasks
        FailTasks = $failtasks
    }
}
$Alltasks+=$result.Tasks
$AllFailTasks+=$result.failtasks
}
# 產生 HTML 表格

$failHtml = $AllFailTasks | ConvertTo-Html -Property '主機IP','排程名稱','狀態','作者','最後一次執行時間','下次執行時間','最後執行結果' -Fragment | Out-String
$allHtml  = $AllTasks     | ConvertTo-Html -Property '主機IP','排程名稱','狀態','作者','最後一次執行時間','下次執行時間','最後執行結果' -Fragment | Out-String

# 包成完整 HTML
$outputHtml = @"
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style>
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid black; padding: 5px; text-align: left; }
th { background-color: #f2f2f2; }
</style>
</head>
<body>
<h2>失敗的排程</h2>
$failHtml
<h2>排程總共</h2>
$allHtml
</body>
</html>
"@
#$outputHtml
$joinpath=Join-Path $PSScriptRoot 'Send_mail_Schedule.ps1'
& $joinpath -outputHtml $outputHtml

#Read-Host -Prompt 'Press Enter to the end'
