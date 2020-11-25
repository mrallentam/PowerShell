#Enterprise CA Configuration Step 4 
#Run this script on the Subordinate Issuing WebEnrollemnt Server

$domainnb="enter domain netbios name"

#copy crt and crl
copy x:\*.* c:\webenroll

$publish cert and crl to active directory
#Publish Root CA Data in to Active Directory 
#publish root ca
certutil –f –dspublish "c:\webenroll\$domainnbROOT_$domainnb Root CA.crt" RootCA

#publish root ca crl
certutil –f –dspublish "c:\webenroll\$domainnb Root CA.crl"

#set up issuing server
Add-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Add-WindowsFeature ADCS-web-enrollment

Install-ADcsCertificationAuthority -CACommonName “$domainnb IssuingCA” -CAType EnterpriseSubordinateCA -CryptoProviderName “RSA#Microsoft Software Key Storage Provider” -HashAlgorithmName SHA512 -KeyLength 4096

Install-ADCSwebenrollment

copy c:\"$domainnb.$domainnb.com_$domainnb IssuingCA.req" x:\

