#get windowsupdate state of all machines
$servers=(get-ADComputer -filter *).Name

###Display last install
Invoke-CimMethod -CimSession $Servers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName GetLastUpdateInstallationDate

##Display last scan
Invoke-CimMethod -CimSession $Servers -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName GetLastScanSuccessDate
 
##Display update level
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\'
$ComputerInfo  = Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-ItemProperty -Path $using:RegistryPath
}
$ComputerInfo | sort PSComputerName | ft PSComputerName,ProductName,EditionID,InstallationType,ReleaseID,UBR
