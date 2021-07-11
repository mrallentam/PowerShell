#Enterprise CA Configuration Step 3
#Run this script on the Offline Root

#Enter domain info
$domainnb="domain net bios name"

#Clearout default publication settings
$ListOfCRL = Get-CACrlDistributionPoint
foreach ($crl in $ListOfCRL) {Remove-CACrlDistributionPoint $crl.uri -Force}

$ListOfAIA = Get-CAAuthorityInformationAccess
foreach ($aia in $ListOfAIA) {Remove-CAAuthorityInformationAccess $aia.uri -Force}

#Set Validation and revocation locations
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl \n10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n2:http://crl.$domainnb.com/WebEnroll/%3%8%9.crl"

certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://crt.$domainnb.com/WebEnroll/%1_%3%4.crt"

#set length of issuance
certutil -setreg ca\ValidityPeriod "Years"
certutil -setreg ca\ValidityPeriodUnits 30
Certutil -setreg CA\CRLPeriodUnits 13
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 0
Certutil -setreg CA\CRLOverlapPeriodUnits 6
Certutil -setreg CA\CRLOverlapPeriod "Hours"

#Restart for new settngs
Restart-Service certsvc

@issue crt and cert
certutil -crl

#copy to mounted drive
copy C:\Windows\System32\CertSrv\CertEnroll\*.* x:\

@change issuance to 15 years
certutil -setreg ca\ValidityPeriod "Years"
certutil -setreg ca\ValidityPeriodUnits 15

#Restart for new settngs
Restart-Service certsvc
