#eassfq turn off drainmode session host 2

#import-module az
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

$status=(get-azvm -name  %sessionhost%  -ResourceGroupName %resourcegroupname% -status).statuses[1].DisplayStatus

if ($status -eq "VM running"){
Update-AzWvdSessionHost -HostPoolName eassfq -ResourceGroupName %resourcegroupname%\ -Name %sessionhost% -AllowNewSession:$false
}
else{
exit
}
