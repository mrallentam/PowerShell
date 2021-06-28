 
 #first domain controller in new forest

#####Enter Variables ####
#Domain Name or Suffix
$domain="xxxx.xxx"

#Domain Netbios Name
$domainnb="xxxx"

# Administrator password, define clear text string for username and password
# Change username if different than Administrator
$userName = 'xxxxxxx'
$userPassword = 'your text password here'

#NIC Configuration
#IP Address
$ipaddress="xxx.xxx.xxx.xxx"

#Default Gateway Address
$defaultgw="xxx.xxx.xxx.xxx"

#subnetmask
$subnetmask="xxx.xxx.xxx.xxx"

#subnetmask prefix legnth
$prefix="xx"

#Dns Server 1
#first DC should always be loopback address unless you have 3rd party dns
$dnssvr1="127.0.0.1"

#DNS Server 2
$dnssvr2="xxx.xxx.xxx.xxx"

###############Start Auto Configuration####################

#Convert Password To SecureString
$secPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

#Create Credentials
$creds = New-Object System.Management.Automation.PSCredential ($userName, $secpassword)

#set static ip
$nic=Get-WmiObject win32_networkadapterconfiguration|where-object {$_.description -like "*hyper-v*"}
$nic.EnableStatic(“$ipaddress”, “$subnetmask”)
$nic.SetGateways(“$defaultgw”, 1)

#Set DNS Configuration
$index = (Get-NetAdapter).ifindex
Set-DnsClientServerAddress -Interfaceindex $netadapter.ifindex -ServerAddresses ("$dnssvr1","$dnssvr2")
Set-DnsClient -InterfaceIndex $netadapter.ifIndex -ConnectionSpecificSuffix "$domain" -UseSuffixWhenRegistering $true

#Install ADDS Windows Feature
Install-WindowsFeature -Name AD-Domain-Services

#DCPromo
$Params = @{
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    DomainName = $domain
    DomainNetbiosName = $domainnb 
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $true
    SafeModeAdministratorPassword = $secpassword
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
}

Install-ADDSForest @Params


 
