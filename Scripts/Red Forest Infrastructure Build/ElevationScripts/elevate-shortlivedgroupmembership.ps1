#elevate to nested group with inputbox and logging
#written by Allen Tam
#Inputbox
function Read-InputBox([string]$Message, [string]$WindowTitle)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle)
}

#elevation duration
[int]$hours = Read-InputBox -Message "Please enter up to 2-8 hours of Domain Admin Elevation" -WindowTitle "Please Enter Number of Elevation Hours" 
$duration= $hours * 60

#get username
$user = $env:USERNAME
$path = "path to log"


$Time = New-TimeSpan -Minutes $duration 
Add-ADGroupMember -Identity ‘$name of nestedgroup’ -Members $user -MemberTimeToLive $Time
$date = get-date
add-content -path $path -value "$user elevated for $hours hours at $date"
