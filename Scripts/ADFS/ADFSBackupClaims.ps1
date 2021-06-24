#Variables
$relayparty = 'relay party name'
$dest = 'C:\backup\adfs\claims\'
 
$Date = Get-Date -Format yyyyMMdd
$Count = 0
 
#Read the RPTs claims
$Claims = (Get-AdfsRelyingPartyTrust -Name $relayparty).IssuanceTransformRules
 
#Ensure nothing is overwritten
$location=($dest+$relayparty+$date+$count+".txt")
$path = Test-Path $location
if ($path -eq $true){
$Count++
}
$savedlocation = ($dest+$relayparty+$date+$count+".txt")
 
#Write the claims to file
$Claims | Out-File $savedlocation

