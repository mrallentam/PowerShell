#get last windows update scan

$servers = (get-ADComputer -filter *).Name


##Display last scan
Invoke-CimMethod -CimSession $Servers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName GetLastScanSuccessDate
