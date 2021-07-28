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
$path = path_to_log

#static shadow principal per domain
$blueforestshadowprincipal = "CN=BLUE-Domain Admins,CN=Shadow Principal Configuration,CN=Services,CN=Configuration,DC=DOMAIN,DC=REDFOREST,DC=com"

[int]$HOURS = Read-InputBox -Message "Please enter up to 2-8 hours of Domain Admin Elevation" -WindowTitle "Please Enter Number of Elevation Hours" 

#Set Shadow principal member duration and write log
$duration= $hours * 60

Set-ADObject -Identity $blueforestshadowprincipal -Add @{'member'="<TTL=$duration,CN= $username,OU=PROD-Shadow,DC=DOMAIN,DC=REDFOREST,DC=com>"}
$datetime=get-date
add-content -path $path -value "$user elevated at $datetime for $duration hours"

