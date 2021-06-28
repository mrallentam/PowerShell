##Power On WVD Host
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



start-azvm -ResourceGroupName %resourcegroupname%  -name %sessionhost%
$rule="WVDSessionhost2 Session monitor"
Get-AzScheduledQueryRule -name "$rule" -resourcegroupname %resourcegroupname% |Update-AzScheduledQueryRule -enabled $false

