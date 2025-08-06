設定主機信任 TrustedHosts

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.6.88"

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.6.81,192.168.6.82,192.168.6.83"

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"
