
#Second domain controller in new forest

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
#Enter DC1 Address
$dnssvr1="xx.xx.xx.xx"

#DNS Server 2
$dnssvr2="127.0.0.1"

#domain controller names
$dc1="dc1 name"
$dc2="dc2 name"
###############Start Auto Configuration####################

#Convert Password To SecureString
$SecPassword = "$userPassword"|ConvertTo-SecureString -AsPlainText -Force

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

#Install ADDS features
Install-WindowsFeature -Name AD-Domain-Services –IncludeManagementTools

#Import ADDS Deployment Module
Import-module ADDSDeployment

Install-ADDSDomainController -CreateDnsDelegation:$false -DatabasePath 'C:\Windows\NTDS' -DomainName '$domain' -InstallDns:$true -LogPath 'C:\Windows\NTDS' -NoGlobalCatalog:$false -SysvolPath 'C:\Windows\SYSVOL' -NoRebootOnCompletion:$true -Force:$true -credential $credential

#move fsmo roles
#import AD module
Import-module active directory
#Fsmo name and numbers.  You can use either to move roles
#PDCEmulator 		0
#RIDMaster		1
#InfrastructureMaster	2
#SchemaMaster		3
#DomainNamingMaster	4

#Set DC1 to hold forest wide fsmo roles Domain Naming Master and Schema Master
Move-ADDirectoryServerOperationMasterRole -OperationMasterRole 3,4 -Identity $dc1 -Verbose -Force -Credential $creds

#Set DC2 to hold domain wide fsmo roles PDC Emulator, Infrastructure Master 
#and RID master
Move-ADDirectoryServerOperationMasterRole -OperationMasterRole 0,1,2 -Identity $dc2 -Verbose -Force -Credential $creds

#Reboot 
Read-host -prompt "Next run AD configuraiton Script"
Shutdown /r /f /t 0
