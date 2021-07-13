#Scan+Download+Update+Reboot if needed

$Updatesneeded=Invoke-CimMethod -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUOperations" -MethodName ScanForUpdates -Arguments @{SearchCriteria="IsInstalled=0 AND AutoSelectOnWebSites=1"}
if ($updatesneeded.Updates){
 Invoke-CimMethod -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUOperations" -MethodName InstallUpdates -Arguments @{Updates=$updatesneeded.Updates}
    }
start-sleep -seconds 2

$reboot=Invoke-CimMethod -Namespace "root/Microsoft/Windows/WindowsUpdate" -ClassName "MSFT_WUSettings" -MethodName IsPendingReboot
if ($reboot -eq $true)
{
    restart-computer
}
start-sleep -seconds 2
