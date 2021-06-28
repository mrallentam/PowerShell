#Password Expiry 7d notification

$ErrorActionPreference="continue"

get-module|where-object {$_.name -notlike "azurerm*"}|remove-module
import-module az.accounts
import-module az.resources
import-module az.compute
import-module az.automation
import-module az.network
import-module az.profile


$Connection=Get-AutomationConnection -Name AzureRunAsConnection

$appid = ($connection).applicationid
$tenantid = ($connection).tenantid
$thumb = ($connection).certificatethumbprint
$subscriptionid = ($connection).subscriptionid 

Connect-AzAccount -TenantId "$tenantid" -ApplicationId "$appid" -CertificateThumbprint "$thumb" -ServicePrincipal


Start-Process -verb runas PowerShell.exe -argumentlist '-command & {
Invoke-WebRequest -Uri "https://eassfazauto.blob.core.windows.net/azautoscripts/pwexpire7d.ps1" -OutFile "c:\scripts\pwexpire7d.ps1"
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "c:\scripts\pwexpire7d.ps1"
$trigger= New-ScheduledTaskTrigger -At 12am -Once
Register-ScheduledTask -Action $action -TaskName PWEXPIRE7d -RunLevel highest -Trigger $trigger
$principal = New-ScheduledTaskPrincipal -UserId eassf\gmsa-azurehw$ -LogonType Password -RunLevel highest
Set-ScheduledTask "PWEXPIRE7d" -Principal $principal
Start-ScheduledTask -TaskName PWEXPIRE7d
}' 

start-sleep -Seconds 20

Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName pwexpire7d -Confirm:$false'

