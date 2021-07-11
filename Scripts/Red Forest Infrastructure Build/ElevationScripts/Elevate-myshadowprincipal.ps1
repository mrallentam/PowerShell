#Simple Elevation script with input box and logging
#Written by Allen Tam

#Inputbox
function Read-InputBox([string]$Message, [string]$WindowTitle)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle)
}

#Script
#get loggedin username
$user = $env:USERNAME

#static shadow principal per domain
$blueforestshadowprincipal = "CN=PROD-Domain Admins,CN=Shadow Principal Configuration,CN=Services,CN=Configuration,DC=pim,DC=contoso,DC=com"

$duration = Read-InputBox -Message "Please enter up to 2-8 hours of Domain Admin Elevation" -WindowTitle "Please Enter Number of Elevation Hours" 

#Set Shadow principal member duration and write log
if ($duration -eq "2"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=120,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 2 hours"
}
if ($duration -eq "3"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=180,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 3 hours"
}
if ($duration -eq "4"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=240,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 4 hours"
}
if ($duration -eq "5"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=300,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 5 hours"
}
if ($duration -eq "6"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=360,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 6 hours"
}
if ($duration -eq "7"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=420,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 7 hours"
}
if ($duration -eq "8"){
Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=480,CN= $username,OU=PROD-Shadow,DC=pim,DC=contoso,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for 8 hours"
} else {
exit}
