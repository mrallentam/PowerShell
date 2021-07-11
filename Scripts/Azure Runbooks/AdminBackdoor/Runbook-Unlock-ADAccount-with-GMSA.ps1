##unlock your account

Param
(
  [Parameter (Mandatory= $true)]
  [String] $username,
  [Parameter (Mandatory= $true)]
  [String] $domain,
  [Parameter (Mandatory= $true)]
  [String] $GMSA
)


$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

Connect-AzAccount `
    -ServicePrincipal `
    -Tenant $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint | Write-Verbose

Start-Process -verb runas PowerShell.exe -argumentlist '-command & {
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "unlock-adaccount -identity $domain\$username"
$trigger= New-ScheduledTaskTrigger -At 12am -Once
Register-ScheduledTask -Action $action -TaskName unlockmyaccount -RunLevel highest -Trigger $trigger
$principal = New-ScheduledTaskPrincipal -UserId $domain\$gmsa -LogonType Password -RunLevel highest
Set-ScheduledTask "unlockmyaccount" -TaskName unlockmyaccount
}'

start-sleep -seconds 5

Start-Process -verb runas PowerShell.exe -argumentlist '-command Start-ScheduledTask -TaskName unlockmyaccount'

start-sleep -seconds 5

Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName unlockmyaccount -Confirm:$false'

