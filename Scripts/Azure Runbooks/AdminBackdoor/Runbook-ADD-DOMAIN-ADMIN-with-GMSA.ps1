

Param
(
  [Parameter (Mandatory= $true)]
  [String] $Username,
  [Parameter (Mandatory= $true)]
  [String] $GMSA
)



import-module az.accounts
import-module az.automation
import-module az.resources
import-module az.compute

$con = Get-AutomationConnection -Name AzureRunAsConnection

Connect-AzAccount `
    -ServicePrincipal `
    -Tenant $con.TenantID `
    -ApplicationId $con.ApplicationID `
    -CertificateThumbprint $con.CertificateThumbprint



Start-Process -verb runas PowerShell.exe -argumentlist '-command & {
import-module activedirectory
Add-ADGroupMember -Identity "domain admins" -Members $username
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "addda"
$trigger= New-ScheduledTaskTrigger -At 12am -Once
Register-ScheduledTask -Action $action -TaskName "addda" -RunLevel highest -Trigger $trigger
$principal = New-ScheduledTaskPrincipal -UserId $GMSA -LogonType Password -RunLevel highest
Set-ScheduledTask "addda" -TaskName "addda"
}'

Start-Process -verb runas PowerShell.exe -argumentlist '-command start-ScheduledTask -TaskName "addda" -Confirm:$false'

Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName "addda" -Confirm:$false'


