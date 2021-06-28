#Backdoor to reset AD password
Param
(
    # user input for username and password 
    [Parameter (Mandatory= $True)]
    [object] $User,
    [Parameter (Mandatory= $True)]
    [object] $Password,
    [Parameter (Mandatory= $True)]
    [object] $GMSA
)

$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Connect-AzAccount `
    -ServicePrincipal `
    -Tenant $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint


$action = New-ScheduledTaskAction -Execute PowerShell.exe -argument "-command Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText '$password' -Force)"
$trigger= New-ScheduledTaskTrigger -At 12am -Once
Register-ScheduledTask -Action $action -TaskName resetadpassword -RunLevel highest -Trigger $trigger


start-sleep -seconds 5


Start-Process -verb runas PowerShell.exe -argumentlist 'invoke-command -scriptblock {
$principal = New-ScheduledTaskPrincipal -UserId $gmsa -LogonType Password -RunLevel highest
Set-ScheduledTask -TaskName resetadpassword -principal $principal
}'


start-sleep -seconds 5

Start-Process -verb runas PowerShell.exe -argumentlist '-command start-ScheduledTask -TaskName resetadpassword'

start-sleep -seconds 5

Start-Process -verb runas PowerShell.exe -argumentlist '-command Unregister-ScheduledTask -TaskName resetadpassword -Confirm:$false'

start-sleep -seconds 5
