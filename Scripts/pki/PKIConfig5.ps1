#Enterprise CA Configuration Step 5
#Run this script on the Offline Root

#enter Domain Netbios Name
$domainnb="domain netbios name"
$computername = "Enter Server name"

import-module pspki

certreq -submit "x:\$domainnb-CA1.$domainnb.com_$domainnb IssuingCA.req"

Get-CertificationAuthority $computername | Get-PendingRequest -ID 2 | Approve-CertificateRequest

certreq -retrieve 2 "x:\$domainnb-CA1.$domainnb.com_$domainnb_IssuingCA.crt"

