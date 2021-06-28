#Enterprise CA Configuration Step 6
#Run this script on the Subordinate Issuing WebEnrollemnt Server

$domainnb="domain netbios name

#copy issued cert to webenroll
copy "x:\$domainnb-CA1.$domainnb.com_$domainnb_IssuingCA.crt" c:\webenroll

#Install Issued Cert
Certutil –installcert "C:\webenroll\$domainnb-CA1.$domainnb.com_$domainnb_IssuingCA.crt"

Restart-service certsvc

#Clear out Default Publication Settings
$ListOfCRL = Get-CACrlDistributionPoint
foreach ($crl in $ListOfCRL) {Remove-CACrlDistributionPoint $crl.uri -Force}

$ListOfAIA = Get-CAAuthorityInformationAccess
foreach ($aia in $ListOfAIA) {Remove-CAAuthorityInformationAccess $aia.uri -Force}

#Configure CRL publication
certutil -setreg CA\CRLPublicationURLs "1:c:\system32\CertSrv\CertEnroll\%3%8%9.crl\n2:http://crl.$domainnb.com/WebEnroll/%3%8%9.crl\n3:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10"
 
#Configure AIA Location
certutil -setreg CA\CACertPublicationURLs "1:c:\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:http://crt.$domainnb.com/WebEnroll/%1_%3%4.crt\n3:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11"
 
#Configure CA and CRL Time limits also need to adjust,
certutil -setreg CA\DSConfigDN CN=Configuration,DC=$domainnb,DC=com
certutil -setreg CA\CRLPeriodUnits 7
certutil -setreg CA\CRLPeriod “Days”
certutil -setreg CA\CRLOverlapPeriodUnits 3
certutil -setreg CA\CRLOverlapPeriod “Days”
certutil -setreg CA\CRLDeltaPeriodUnits 0
certutil -setreg ca\ValidityPeriodUnits 3
certutil -setreg ca\ValidityPeriod “Years”
certutil -setreg CA\CRLFlags +CRLF_REVCHECK_IGNORE_OFFLINE
certutil -setreg policy\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2

#restart for new settings 
Restart-Service certsvc
 
#Get CRL and CRT
certutil -crl

copy C:\Windows\System32\CertSrv\CertEnroll\*.* c:\webenroll
$crtname=(get-childitem -path C:\Windows\System32\CertSrv\CertEnroll\*.crt).name
$crlname=(get-childitem -path C:\Windows\System32\CertSrv\CertEnroll\*.crl -Exclude *+*.crl).name


Get the issuing cert crt and crl names that were just copied from certenroll

#publish root ca
certutil –f –dspublish "c:\webenroll\$crtfilename" SUBCA

#publish root ca crl
certutil –f –dspublish "c:\webenroll\$crlfilename.crl"
