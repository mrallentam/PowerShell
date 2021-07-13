#Get reboot state on all servers


$servers=(get-ADComputer -filter *).Name

#$reboot=Invoke-CimMethod -computername $computers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName IsPendingReboot

Invoke-CimMethod -computername $computers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName IsPendingReboot

