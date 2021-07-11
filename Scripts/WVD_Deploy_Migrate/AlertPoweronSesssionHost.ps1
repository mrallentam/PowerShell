##Poweroff WVDHost
import-module az
$ErrorActionPreference="continue"

import-module az.accounts
import-module az.automation
import-module az.compute
import-module az.resources


$con = Get-AutomationConnection -Name "AzureRunAsConnection"   

    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $con.TenantId `
        -ApplicationId $con.ApplicationId `
        -CertificateThumbprint $con.CertificateThumbprint 


#Check sessionhost 1 for buffer threshold of available sessions

$workspaceid="%WorkspaceID%"
$query='Perf 
| where Computer contains "%sessionhost1%"
| where ObjectName == "Terminal Services"
| where CounterName == "Active Sessions"
| where TimeGenerated > ago(90s)
| project CounterValue'

$activesessions = (invoke-azoperationalinsightsquery -WorkspaceId $workspaceid -query $query).results
if ($activesessions -lt 2){
stop-azvm -ResourceGroupName rf1-qa-rg -name %sessionhost2%
[system.gc]::Collect()
$rule="WVDSessionhost2 Session monitor"
Get-AzScheduledQueryRule -name "$rule" -resourcegroupname %resourcegroupname% |Update-AzScheduledQueryRule -enabled $false
}
