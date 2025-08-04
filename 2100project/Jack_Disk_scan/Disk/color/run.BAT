@echo off
REM —— 關掉每一行執行時的回顯（不顯示指令本身，只顯示輸出）
REM 下面這行呼叫 PowerShell 腳本，並把參數傳過去
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_COLOR.ps1" 
REM -WatchFolder '\\192.168.6.88\c$\2100\SAVE\ERROR' -Threshold 5
REM 取出剛剛 PowerShell 執行後的回傳碼（exit code）
set "rc=%ERRORLEVEL%"

REM 根據回傳碼判斷失敗或成功
if %rc% neq 0 (
    echo PowerShell 腳本失敗，錯誤碼：%rc%
) else (
    echo PowerShell 腳本成功完成，錯誤碼：%rc%
)

REM 讓這個 batch 也帶回同樣的錯誤碼給呼叫者（比如排程器）
REM Exit /B %rc%
