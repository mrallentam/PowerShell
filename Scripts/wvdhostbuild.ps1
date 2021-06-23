

#disable ie enhanced mode
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' /v IsInstalled /t REG_DWORD /d 00000000
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components' /v IsInstalled /t REG_DWORD /d 00000000
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' /v IsInstalled /t REG_DWORD /d 00000000


mkdir c:\install
mkdir c:\install\fslogix
mkdir c:\scripts
mkdir c:\temp
$s1="https://link to /ndp48-x86-x64-allos-enu.exe"
$s2="https://link to /windowsdesktop-runtime-3.1.14-win-x64.exe"
$s3="https://link to /windowsdesktop-runtime-5.0.5-win-x64.exe"
$s4="https://link to /microsoft-edgexxx.msi "
$s5="https://link to windowsupdate.script"
$s6="https://link to /FSLogix_Apps_2.9.7654.46150.zip"
$s7="https://link to /Microsoft.RDInfra.RDAgent.Installer-x64-1.0.2548.6500.msi"
$s8="https://link to /Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi"
$d1="c:\install\ndp48-x86-x64-allos-enu.exe"
$d2="c:\install\windowsdesktop-runtime-3.1.14-win-x64.exe"
$d3="c:\install\https://swlib1.blob.core.windows.net/files/windowsdesktop-runtime-5.0.5-win-x64.exe"
$d4="c:\install\microsoft-edgexxxx.msi"
$d5="c:\scripts\windowsupdate script"
$d6="c:\install\FSLogix_Apps_2.9.7654.46150 (1).zip"
$d7="c:\install\Microsoft.RDInfra.RDAgent.Installer-x64-1.0.2548.6500.msi"
$d8="c:\install\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi"

start-bitstransfer -source $s1 -destination $d1
start-bitstransfer -source $s2 -destination $d2
start-bitstransfer -source $s3 -destination $d3
Start-bitstransfer -source $s4 -destination $d4
start-bitstransfer -source $s5 -destination $d5
start-bitstransfer -source $s6 -destination $d6
start-bitstransfer -source $s7 -destination $d7
Start-bitstransfer -source $s8 -destination $d8
Expand-Archive -Path $d1 -DestinationPath C:\install\fslogix

& "$d1 /install /quiet /norestart"
& "$d2 /install /quiet /norestart"
& "$d3 /install /quiet /norestart"


#enable TLS
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" /v DefaultSecureProtocols /t REG_DWORD /d 0xAA0
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttpr" /v DefaultSecureProtocols /t REG_DWORD /d 0xAA0
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v DisabledByDefault /t REG_DWORD /d 00000000
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v Enabled /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v DisabledByDefault /t REG_DWORD /d 00000000
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v Enabled /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319]" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319]" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 00000001

#open firewall ports
netsh advfirewall firewall add rule name="infromvnet" dir=in action=allow protocol=ANY remoteip=%remote ip scope%
netsh advfirewall firewall add rule name="rdpinfromequifax" dir=in action=allow protocol=tcp localport=3389 remoteip=%remove IP Scope%
netsh advfirewall firewall add rule name="wvdshortpathinfromequifax" dir=in action=allow protocol=udp localport=3390 remoteip=10.0.0.0/8
netsh advfirewall firewall add rule name="rdpinfromequifax2" dir=in action=allow protocol=tcp localport=3389 remoteip=172.16.0.0/12
netsh advfirewall firewall add rule name="wvdshortpathinfromequifax2" dir=in action=allow protocol=udp localport=3390 remoteip=172.16.0.0/12

#configure NLA
#credssp
remove-item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP'

#configure NLA
New-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders' -NAME 'SecurityProviders'-value 'msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll,credssp.dll' -propertytype 'string' -force
New-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -NAME 'Security Packages'-value 'tspkg' -propertytype 'multistring' -force
New-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters' -NAME 'TryIPSPN'-value '1' -propertytype 'dword' -force
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -NAME 'authenticationlevel'-value '1' -propertytype 'dword' -force


#update powershell
install-module powershellget -force
install-module az -force
update-module


#create windowsupdate script
"import-module windowsupdateprovider `r`n"|out-file c:\scripts\windowsupdate.txt -append
"2x2updates = start-wuscan `r`n"|out-file c:\scripts\windowsupdate.txt -append
"foreach (2x2update in 2x2updates){Install-WUUpdates -updates 2x2update} `r`n"|out-file c:\scripts\windowsupdate.txt -append
"2x2action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument '-noprofile -executionpolicy bypass -file c:\scripts\addtodomain.ps1' `r`n"|out-file c:\scripts\windowsupdate.txt -append
"2x2timespan = new-timespan -minutes 1 `r`n"|out-file c:\scripts\windowsupdate.txt -append
"Register-ScheduledTask -Action 2x2action -TaskName addtodomain -RunLevel highest -Trigger 2x2trigger `r`n"|out-file c:\scripts\windowsupdate.txt -append
"shutdown /r /f /t 60 `r`n"|out-file c:\scripts\windowsupdate.txt -append
"Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName windowsupdate -Confirm:$false'"|out-file c:\scripts\windowsupdate.txt -append
$content = Get-Content -Path 'C:\scripts\windowsupdate.txt'
$newContent = $content -replace '2x2', '$'
$newContent | Set-Content -Path 'C:\scripts\windowsupdate.ps1'

#add machine to domain
"3x3dausername = 'domainadmin'"|out-file c:\scripts\addtodomain.txt -append
"3x3secpassword = ConvertTo-SecureString 'whatever password is' -AsPlainText -Force"|out-file c:\scripts\addtodomain.txt -append
"3x3Creds = New-Object System.Management.Automation.PSCredential ('3x3dausername', '3x3secpassword')"|out-file c:\scripts\addtodomain.txt -append
"add-computer -domainname %domain.com% -oupath %oupath% -credential 3x3creds"|out-file c:\scripts\addtodomain.txt -append
"3x3action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument '-noprofile -executionpolicy bypass -file c:\scripts\configuresessionhost.txt';"|out-file c:\scripts\addtodomain.txt -append
"3x3timespan = new-timespan -minutes 1"|out-file c:\scripts\addtodomain.txt -append
"3x3trigger= New-ScheduledTaskTrigger -randomdelay 3x3timespan -AtStartup;"|out-file c:\scripts\addtodomain.txt -append
"Register-ScheduledTask -Action 3x3action -TaskName configuresessionshost -RunLevel highest -Trigger 3x3trigger"|out-file c:\scripts\addtodomain.txt -append
"shutdown /r /f /t 60"|out-file c:\scripts\addtodomain.txt -append
"Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName addtodomain -Confirm:3x3false'"|out-file c:\scripts\addtodomain.txt -append
$content1 = Get-Content -Path 'c:\scripts\addtodomain.txt'
$newContent1 = $content1 -replace '3x3', '$'
$newContent1 | Set-Content -Path 'C:\scripts\addtodomain.ps1'

#create configuresessionhost script|out-file c:\scripts\configuresessionhost.txt -append
"Add-LocalGroupMember -group 'Remote Desktop Users' -member 'domain group'"|out-file c:\scripts\configuresessionhost.txt -append
"Add-WindowsFeature rds-rd-server"|out-file c:\scripts\configuresessionhost.txt -append
"x4xaction = New-ScheduledTaskAction -Execute PowerShell.exe -Argument '-noprofile -executionpolicy bypass -file c:\scripts\configurewvd.ps1';"|out-file c:\scripts\configuresessionhost.txt -append
"x4xtimespan = new-timespan -minutes 1"|out-file c:\scripts\configuresessionhost.txt -append
"x4xtrigger= New-ScheduledTaskTrigger -randomdelay x4xtimespan -AtStartup;"|out-file c:\scripts\configuresessionhost.txt -append
"Register-ScheduledTask -Action x4xaction -TaskName configurewvd -RunLevel highest -Trigger x4xtrigger"|out-file c:\scripts\configuresessionhost.txt -append
"shutdown /r /f /t 60"|out-file c:\scripts\configuresessionhost.txt -append
"Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName configuresessionhost -Confirm:x4xfalse'"|out-file c:\scripts\configuresessionhost.txt -append
$content2 = Get-Content -Path 'c:\scripts\configuresessionhost.txt'
$newContent2 = $content2 -replace 'x4x', '$'
$newContent2 | Set-Content -Path 'c:\scripts\configuresessionhost.ps1'


#create configure wvd script
"& 'C:\install\fslogix\x64\Release\FSLogixAppsSetup.exe' /install /quiet /norestart"|out-file c:\scripts\configurewvd.txt -append
"msiexec.exe /i 'c:\install\Microsoft.RDInfra.RDAgent.Installer-x64-1.0.2548.6500.msi' /quiet /norestart"|out-file c:\scripts\configurewvd.txt -append
"msiexec.exe /i 'c:\install\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi' /quiet /norestart"|out-file c:\scripts\configurewvd.txt -append
"#configure agents"|out-file c:\scripts\configurewvd.txt -append
"x5xtoken =' ADD token here'"|out-file c:\scripts\configurewvd.txt -append
"x5xpath='hklm:\software\microsoft\rdinfraagent'"|out-file c:\scripts\configurewvd.txt -append
"Remove-ItemProperty -Path x5xpath -Name 'isregistered' -Force"|out-file c:\scripts\configurewvd.txt -append
"Remove-ItemProperty -Path x5xpath -Name 'RegistrationToken' -Force"|out-file c:\scripts\configurewvd.txt -append
"new-itemproperty -path x5xpath -name IsRegistered -value 0 -propertytype dword"|out-file c:\scripts\configurewvd.txt -append
"new-itemproperty -path x5xpath -name RegistrationToken -value x5xtoken -propertytype string"|out-file c:\scripts\configurewvd.txt -append
"x5xWinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'"|out-file c:\scripts\configurewvd.txt -append
"New-ItemProperty -Path x5xWinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force"|out-file c:\scripts\configurewvd.txt -append
"New-ItemProperty -Path x5xWinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force"|out-file c:\scripts\configurewvd.txt -append
"#install edge"|out-file c:\scripts\configurewvd.txt -append
"msiexec.exe /i 'c:\install\microsoft-edgexxx.msi'"|out-file c:\scripts\configurewvd.txt -append
"#remove ie"|out-file c:\scripts\configurewvd.txt -append
"dism /online /disable-feature /featurename:Internet-Explorer-Optional-amd64 /norestart"|out-file c:\scripts\configurewvd.txt -append
"shutdown /r /f /t 60"|out-file c:\scripts\configurewvd.txt -append
"Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName configurewvd -Confirm:x5xfalse'"|out-file c:\scripts\configurewvd.txt -append
$content3 = Get-Content -Path 'c:\scripts\configurewvd.txt'
$newContent3 = $content3 -replace 'x5x', '$'
$newContent3 | Set-Content -Path 'c:\scripts\configurewvd.ps1'


#schedule windows update script and start script
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-noprofile -executionpolicy bypass -file c:\scripts\windowsupdate.ps1";
$timespan = new-timespan -minutes 1
$trigger= New-ScheduledTaskTrigger -randomdelay $timespan -atstartup;
Register-ScheduledTask -Action $action -TaskName windowsupdate -RunLevel highest -Trigger $trigger
start-sleep -seconds 5
Start-Process -verb runas PowerShell.exe -argumentlist '-command Start-ScheduledTask -TaskName windowsupdate
