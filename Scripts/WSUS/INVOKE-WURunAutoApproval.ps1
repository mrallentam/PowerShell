##Run Auto Approval rules

$wsus=[Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()

#Get and run auto approve rules
$rules = $wsus.GetInstallApprovalRules()
foreach ($rule in $rules){
$rule.Enabled = $true
$rule.ApplyRule()
}