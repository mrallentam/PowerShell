#Build nps server

#variables
# Enter domain admin info
$creds=get-credential

#NIC Configuration
#IP Address
$ipaddress="xxx.xxx.xxx.xxx"

#Default Gateway Address
$defaultgw="xxx.xxx.xxx.xxx"

#subnetmask
$subnetmask="xxx.xxx.xxx.xxx"

#subnetmask prefix legnth
$prefix="xx"

$dnssvr1="xx.xx.xx.xx"
$dnssvr2="xx.xx.xx.xx"

#Domain Name or Suffix
$domain="xxxx.xxx"

#Domain Netbios Name
$domainnb="xxxx"



###############Start Auto Configuration####################

#set static ip
$nic=Get-WmiObject win32_networkadapterconfiguration|where-object {$_.description -like "*hyper-v*"}
$nic.EnableStatic(“$ipaddress”, “$subnetmask”)
$nic.SetGateways(“$defaultgw”, 1)

#Set DNS Configuration
$index = (Get-NetAdapter).ifindex
Set-DnsClientServerAddress -Interfaceindex $netadapter.ifindex -ServerAddresses ("$dnssvr1","$dnssvr2")
Set-DnsClient -InterfaceIndex $netadapter.ifIndex -ConnectionSpecificSuffix "$domain" -UseSuffixWhenRegistering $true


#Install NPS Service
Install-WindowsFeature NPAS -IncludeManagementTools



#Reboot 
Read-host -prompt "Leave for RDS Deploy script to configure"
Shutdown /r /f /t 0
