#Active Directory Configuration
#Configure
#1.  Create OU Structure
#2.  Sites-Services
#3.  Time
#4.  DNS
#5.  Enable Recyclebin

#define names
$ForestFQDN = "xxxxx.xxx"
$SchemaDC   = "dc1 fqdn"

#define Base DN and OU DN
#fill in Base DN to use as scripted
$baseDN = "dc=domain,dc=com"
$resourcesDN = "OU=Resources," + $baseDN

# Define DNS and Sites & Services Settings
$IPv4netID = "xxx.xxx.xxx.xxx/24"

#enter different name if wanted
$siteName = "Default-First-Site-Name"

#Location
$location = "Enter Location"

# Authoritative Internet Time Servers (Change if you you want different)
$timePeerList = "0.us.pool.ntp.org 1.us.pool.ntp.org"

###########Begin Auto Configuration################
#Create OU Structure 
New-ADOrganizationalUnit "Resources" -path $baseDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Privileged Users" -path $resourcesDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Security Groups" -path $resourcesDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Service Accounts" -path $resourcesDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Workstations" -path $resourcesDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Servers" -path $resourcesDN -ProtectedFromAccidentalDeletion
New-ADOrganizationalUnit "Users" -path $resourcesDN -ProtectedFromAccidentalDeletion
# Add DNS Reverse Lookup Zones
Add-DNSServerPrimaryZone -NetworkID $IPv4netID -ReplicationScope 'Forest' -DynamicUpdate 'Secure'

# Make Changes to Sites & Services
$defaultSite = Get-ADReplicationSite | Select DistinguishedName
#Rename-ADObject $defaultSite.DistinguishedName -NewName $siteName
New-ADReplicationSubnet -Name $IPv4netID -site $siteName -Location $location

# Re-Register DC's DNS Records
Register-DnsClient

# Enable Default Aging/Scavenging Settings for All Zones and this DNS Server
Set-DnsServerScavenging –ScavengingState $True –ScavengingInterval 7:00:00:00 –ApplyOnAllZones
$Zones = Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False -and $_.ZoneName -ne 'TrustAnchors'}
$Zones | Set-DnsServerZoneAging -Aging $True

# Set Time Configuration
w32tm /config /manualpeerlist:$timePeerList /syncfromflags:manual /reliable:yes /update

#Enable Recycle Bin
Enable-ADOptionalFeature –Identity 'Recycle Bin Feature' –Scope ForestOrConfigurationSet –Target $ForestFQDN -Server $SchemaDC -confirm:$false

Read-host -prompt "Run Users script"
