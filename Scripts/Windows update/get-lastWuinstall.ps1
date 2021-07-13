#get last time windows updates were installed


$servers=(get-ADComputer -filter *).Name

###Display last install
Invoke-CimMethod -CimSession $Servers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName GetLastUpdateInstallationDate
