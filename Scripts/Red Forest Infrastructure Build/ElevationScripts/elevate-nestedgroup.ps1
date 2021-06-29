#elevate to nested group with inputbox and logging
#written by Allen Tam
#Inputbox
function Read-InputBox([string]$Message, [string]$WindowTitle)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle)
}

#elevation duration
$duration = Read-InputBox -Message "Please enter up to 2-8 hours of Domain Admin Elevation" -WindowTitle "Please Enter Number of Elevation Hours" 

#get username
$user = $env:USERNAME
$path = "path to log"

if ($duration -eq "2"){
$Time = New-TimeSpan -Minutes 120 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 2 hours at $date"
}
if ($duration -eq "3"){
$Time = New-TimeSpan -Minutes 180 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 3 hours at $date"
}
if ($duration -eq "4"){
$Time = New-TimeSpan -Minutes 240 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 4 hours at $date"
}
if ($duration -eq "5"){
$Time = New-TimeSpan -Minutes 300 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 5 hours at $date"
}
if ($duration -eq "6"){
$Time = New-TimeSpan -Minutes 360 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 6 hours at $date"
}
if ($duration -eq "7"){
$Time = New-TimeSpan -Minutes 420 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 7 hours at $date"
}
if ($duration -eq "8"){
$Time = New-TimeSpan -Minutes 480 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for 8 hours at $date"
} else {
exit}



