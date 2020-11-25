#Enterprise CA Configuration Step 1 
#Run this script on the Offline Root
$rootdn="dc=domain,dc=com"
$domainnb="domain netbios name"

#Setup Standalone Root CA
$rootcaname="$Domainnb Root CA"

#ADD windows feature
Add-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

#install pspki
Install-Module -Name PSPKI -force
 
#Install Root CA
Install-ADcsCertificationAuthority -CACommonName “$Domainnb Root CA” -CAType StandaloneRootCA -CryptoProviderName “RSA#Microsoft Software Key Storage Provider” -HashAlgorithmName SHA512 -KeyLength 4096 -ValidityPeriod Years -ValidityPeriodUnits 30

#Set DSConfiguration
certutil.exe –setreg ca\DSConfigDN 'CN=Configuration,$rootdn'

#Set firewall rules
netsh int ipv4 set dynamicport tcp start=54445 num=555
netsh int ipv4 set dynamicport udp start=54445 num=555
netsh int ipv6 set dynamicport tcp start=54445 num=555
netsh int ipv6 set dynamicport udp start=54445 num=555