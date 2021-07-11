#Base server configuration script
#set variables
$creds=get-credential
$domain = "name of domain"
$newcomputername="Enter computer name"

#rename computer no reboot
$hostname = hostname
Rename-computer -computername $hostname -newname $newcomputername

mkdir c:\scripts
mkdir c:\temp
mkdir c:\install
$s="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/bcae64a1-5bf9-40b6-bff4-cd8301415597/MicrosoftEdgeBetaEnterpriseX64.msi"
$d1="c:\install\MicrosoftEdgeBetaEnterpriseX64.msi"
$s2="https://gallery.technet.microsoft.com/Net-Cease-Blocking-Net-1e8dcb5b/file/165596/1/NetCease.zip"
$d2="c:\install\NetCease.zip"
$s3="https://go.microsoft.com/fwlink/?linkid=2088631"
start-bitstransfer -source $s1 -destination $d1
start-bitstransfer -source $s2 -destination $d2
expand-archive c:\install\netcease.zip -destination c:\scripts
(Invoke-WebRequest -Uri "$s3").Links.Href

#disable IE Enhanced Security
$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer

#install dot net 4.8
cd c:\install
ndp48-x86-x64-allos-enu.exe /q /norestart

#Install dotnet 5
https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.ps1

#Install Microsoft Edge
msiexec.exe /i MicrosoftEdgeBetaEnterpriseX64.msi /quiet /norestart

#disable IE 11
dism /online /Disable-Feature /FeatureName:Internet-Explorer-Optional-amd64

#search download install windows updates
Start-Process -verb runas PowerShell.exe -argumentlist '-command invoke-command -scriptblock {
$C = "IsInstalled=0 and IsHidden=0"
$S = New-Object -ComObject Microsoft.Update.Searcher 
$Sr = $S.Search($c).Updates
$Ss = New-Object -ComObject Microsoft.Update.Session 
$Dl = $Ss.CreateUpdateDownloader()
$Dl.Updates = $Sr
$Dl.Download()
$Inst = New-Object -ComObject Microsoft.Update.Installer
$Inst.Updates = $Sr
$R = $Inst.Install()
#If ($R.rebootRequired) { shutdown /r /f /t 0 } 
}'
 
#Enable tcpip v4 over v6
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /v DisabledComponents /t REG_DWORD /d 0x20 /f

#enable strong crypto and tls 1.2
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v SystemDefaultTlsVersions /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 00000001
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\CLIENT"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\CLIENT" /v DisabledByDefault /t REG_DWORD /d 0
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\CLIENT" /v Enabled /t REG_DWORD /d 1
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\SERVER" /v DisabledByDefault /t REG_DWORD /d 0
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\SERVER" /v Enabled /t REG_DWORD /d 1

#add computer to domain no reboot
Add-Computer -DomainName $domain -credential $creds 

#enable winrm
enable-psremoting -force

#run netcease and reboot
& "c:\scripts\netcease.ps1"
