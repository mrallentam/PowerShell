$dc1="%dc1name%"
$dc2="%dc2name%"

$dc1fqdn="%server fqdn%"
$dc2fqdn="%server fqdn%"
$dc1dn=(get-addomaincontroller -identity $dc1).computerobjectdn
$dc2dn=(get-addomaincontroller -identity $dc12).computerobjectdn

import-module activedirectory

invoke-command -ScriptBlock {stop-service dfsr -force} -ComputerName $dc1fqdn

start-sleep -seconds 1

invoke-command -ScriptBlock {stop-service dfsr -force} -ComputerName $dc2fqdn

start-sleep -seconds 1

get-adobject "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$dc1dn" -properties *|
Set-ADObject -Replace @{‘msDFSR-Enabled’=$false; ‘msDFSR-options’=1}

start-sleep -seconds 1

get-adobject "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$dc2dn" -properties *|
Set-ADObject -Replace @{‘msDFSR-Enabled’=$false}

start-sleep 1

invoke-command -scriptblock {repadmin /syncall $dc1fqdn /APeD} -computername $dc1fqdn

start-sleep -seconds 1

invoke-command -scriptblock {repadmin /syncall $dc2fqdn /APeD} -computername $dc2fqdn

start-sleep -seconds 1

invoke-command -ScriptBlock {start-service dfsr} -ComputerName $dc1fqdn

start-sleep -seconds 1

get-adobject "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$dc1dn" -properties *|
Set-ADObject -Replace @{‘msDFSR-Enabled’=$true}

start-sleep -seconds 1

invoke-command -ScriptBlock {dfsrdiag pollad} -ComputerName $dc1fqdn

start-sleep -seconds 1

invoke-command -ScriptBlock {repadmin /syncall $dc1fqdn /APed} -ComputerName $dc1fqdn

start-sleep -seconds 1

invoke-command -ScriptBlock {start-service dfsr} -ComputerName $dc2fqdn

start-sleep -seconds 1

get-adobject "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$dc2dn" -properties *|
Set-ADObject -Replace @{‘msDFSR-Enabled’=$true}

start-sleep -seconds 1

invoke-command -ScriptBlock {dfsrdiag pollad} -ComputerName $dc2fqdn

start-sleep -seconds 1

invoke-command -ScriptBlock {repadmin /syncall $dc2fqdn /APed} -ComputerName $dc2fqdn


