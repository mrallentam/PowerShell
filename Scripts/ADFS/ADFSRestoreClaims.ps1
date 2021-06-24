$Relay = 'relaying party trust name'
$backupfile = 'c:\path\To\backup.txt.txt'
 
#Read the claim backup
[string]$Backup = Get-Content $backupfile
 
#overwrite with backup
Set-AdfsRelyingPartyTrust -TargetName $relay -IssuanceTransformRules $Backup
