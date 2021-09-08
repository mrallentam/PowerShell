######SCRIPT FOR FULL INSTALL AND CONFIGURE ON STANDALONE MACHINE#####
#Require elevation for script run  -RunAsAdministrator

$ErrorActionPreference = 'silentlycontinue'

#Unblock all files required for script
Get-ChildItem *.ps*1 -recurse | Unblock-File

#Set Directory to PSScriptRoot
mkdir c:\temp\scriptroot
Set-Location c:\temp\scriptroot
$scriptroot="c:\temp\scriptroot"

#Download configuration files
$url="https://github.com/mrallentam/PowerShell/blob/master/Scripts/DoDStigScripts/Files.zip"
$outfile="$scriptroot\files.zip"
Invoke-WebRequest -Uri $url -OutFile $outfile
mkdir "$scriptroot\files"
expand-archive -Path "$scriptroot\files.zip" -DestinationPath "$scriptroot\files"

#Remove and Refresh Local Policies
Remove-Item -Recurse -Force "$env:WinDir\System32\GroupPolicy" | Out-Null
Remove-Item -Recurse -Force "$env:WinDir\System32\GroupPolicyUsers" | Out-Null
secedit /configure /cfg "$env:WinDir\inf\defltbase.inf" /db defltbase.sdb /verbose | Out-Null

#Mitigations
#####SPECTURE MELTDOWN#####
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Type "DWORD" -Value 72 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Type "DWORD" -Value 3 -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Virtualization" -Name MinVmVersionForCpuBasedMitigations -Type "String" -Value "1.0" -Force

#Disable LLMNR
New-Item -Path "HKLM:\Software\policies\Microsoft\Windows NT\" -Name "DNSClient" -Force
Set-ItemProperty -Path "HKLM:\Software\policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Type "DWORD" -Value 0 -Force

#Disable TCP Timestamps
netsh int tcp set global timestamps=disabled

#Enable DEP
BCDEDIT /set "{current}" nx OptOut
Set-Processmitigation -System -Enable DEP
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\" -Name "Explorer" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoDataExecutionPrevention" -Type "DWORD" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableHHDEP" -Type "DWORD" -Value 0 -Force

#Enable SEHOP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "DisableExceptionChainValidation" -Type "DWORD" -Value 0 -Force

#Disable NetBIOS by updating Registry
$key = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
Get-ChildItem $key | ForEach-Object { 
  Write-Host("Modify $key\$($_.pschildname)")
  $NetbiosOptions_Value = (Get-ItemProperty "$key\$($_.pschildname)").NetbiosOptions
  Write-Host("NetbiosOptions updated value is $NetbiosOptions_Value")
}
    
#Disable WPAD
New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\" -Name "Wpad" -Force
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" -Name "Wpad" -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" -Name "WpadOverride" -Type "DWORD" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" -Name "WpadOverride" -Type "DWORD" -Value 1 -Force

#Enable LSA Protection/Auditing
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\" -Name "LSASS.exe" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" -Name "AuditLevel" -Type "DWORD" -Value 8 -Force

#Disable Windows Script Host
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\" -Name "Settings" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type "DWORD" -Value 0 -Force
    
#Disable WDigest
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest" -Name "UseLogonCredential" -Type "DWORD" -Value 0 -Force

#Block Untrusted Fonts
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel\" -Name "MitigationOptions" -Type "QWORD" -Value "1000000000000" -Force
    
#Disable Hibernate
powercfg -h off
    
#SMB Hardening
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "RestrictNullSessAccess" -Type "DWORD" -Value 1 -Force 
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "RestrictAnonymousSAM" -Type "DWORD" -Value 1 -Force  
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" -Value 256 -Force 
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name "RestrictAnonymous" -Type "DWORD" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -Type "DWORD" -Value 1 -Force
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart 
Set-SmbClientConfiguration -RequireSecuritySignature $True -Force
Set-SmbClientConfiguration -EnableSecuritySignature $True -Force
Set-SmbServerConfiguration -EncryptData $True -Force 
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force    
    
#Disable Powershell v2
Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart 
    
#Enable potentially unwanted apps    
Set-MpPreference -PUAProtection 1


#STIG Addendum
#Basic authentication for RSS feeds over HTTP must not be used.
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\" -Name "Feeds" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" -Name AllowBasicAuthInClear -Type DWORD -Value 0 -Force
#InPrivate browsing in Microsoft Edge must be disabled.
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\" -Name "Main" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name AllowInPrivate -Type DWORD -Value 0 -Force
#Windows 10 must be configured to prevent Microsoft Edge browser data from being cleared on exit.
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\" -Name "Privacy" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Privacy" -Name ClearBrowsingHistoryOnExit -Type DWORD -Value 0 -Force


#VM and VDI Optimizations
#VM Performance Improvements
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Type DWORD -Value 2
# Apply appearance customizations to default user registry hive, then close hive file
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name IconsOnly -Type DWORD -Value 1 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewAlphaSelect -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewShadow -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCompColor -Type DWORD -Value 1 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowInfoTip -Type DWORD -Value 1 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAnimations -Type DWORD -Value 0 -Force
NEW-ITEM -path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer" -name VisualEffects -force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Type DWORD -Value 3 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\DWM" -Name EnableAeroPeek -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\DWM" -Name AlwaysHiberNateThumbnails -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop" -Name DragFullWindows -Type STRING -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop" -Name FontSmoothing -Type STRING -Value 2 -Force
New-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop\WindowMetrics" -Name MinAnimate -Type STRING -Value 0 -Force
new-item -path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\" -name StoragePolicy -force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name 01 -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338393Enabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353694Enabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353696Enabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338388Enabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338389Enabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SystemPaneSuggestionsEnabled -Type DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\Default\Control Panel\International\User Profile" -Name HttpAcceptLanguageOptOut -Type DWORD -Value 1 -Force
New-Item -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\" -name Microsoft.Windows.Photos_8wekyb3d8bbwe -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" -Name Disabled -Type DWORD -Value 1 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" -Name DisabledByUser -Type DWORD -Value 1 -Force
New-Item -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\" -name Microsoft.SkypeApp_kzf8qxf38zg5c -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" -Name Disabled -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" -Name DisabledByUser -Type DWORD -Value 1 -Force
New-Item -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\" -name Microsoft.YourPhone_8wekyb3d8bbwe -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" -Name Disabled -Type DWORD -Value 1 -Force
New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" -Name DisabledByUser -Type DWORD -Value 1 -Force
New-Item -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\" -Name "Advanced" -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name IconsOnly -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewAlphaSelect -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewShadow -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCompColor -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowInfoTip -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAnimations -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Type DWORD -Value 3 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\DWM" -Name EnableAeroPeek -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\DWM" -Name AlwaysHiberNateThumbnails -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop" -Name DragFullWindows -Type STRING -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop" -Name FontSmoothing -Type STRING -Value 2 -Force
Set-ItemProperty -Path "HKLM:\Default\Control Panel\Desktop\WindowMetrics" -Name MinAnimate -Type STRING -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name 01 -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338393Enabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353694Enabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353696Enabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338388Enabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338389Enabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SystemPaneSuggestionsEnabled -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\Default\Control Panel\International\User Profile" -Name HttpAcceptLanguageOptOut -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" -Name Disabled -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" -Name DisabledByUser -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" -Name Disabled -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" -Name DisabledByUser -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" -Name Disabled -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" -Name DisabledByUser -Type DWORD -Value 1 -Force
& REG UNLOAD HKLM\DEFAULT


#Nessus Plugin ID 63155 - Microsoft Windows Unquoted Service Path Enumeration
# https://github.com/VectorBCO/windows-path-enumerate/blob/development/Windows_Path_Enumerate.ps1
ForEach ($i in 1..2) {
        # Get all services
        $FixParameters = @()
        If ($i = 1) {
            $FixParameters += @{"Path" = "HKLM:\SYSTEM\CurrentControlSet\Services\" ; "ParamName" = "ImagePath" }
        }
        If ($i = 2) {
            $FixParameters += @{"Path" = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" ; "ParamName" = "UninstallString" }
            # If OS x64 - adding paths for x86 programs
            If (Test-Path "$($env:SystemDrive)\Program Files (x86)\") {
                $FixParameters += @{"Path" = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" ; "ParamName" = "UninstallString" }
            }
        }
        $PTElements = @()
        ForEach ($FixParameter in $FixParameters) {
            Get-ChildItem $FixParameter.Path -ErrorAction SilentlyContinue | ForEach-Object {
                $SpCharREGEX = '([\[\]])'
                $RegistryPath = $_.name -Replace 'HKEY_LOCAL_MACHINE', 'HKLM:' -replace $SpCharREGEX, '`$1'
                $OriginalPath = (Get-ItemProperty "$RegistryPath")
                $ImagePath = $OriginalPath.$($FixParameter.ParamName)
                If ($i = 1, 2) {
                    If ($($OriginalPath.$($FixParameter.ParamName)) -match '%(?''envVar''[^%]+)%') {
                        $EnvVar = $Matches['envVar']
                        $FullVar = (Get-ChildItem env: | Where-Object { $_.Name -eq $EnvVar }).value
                        $ImagePath = $OriginalPath.$($FixParameter.ParamName) -replace "%$EnvVar%", $FullVar
                        Clear-Variable Matches
                    } # End If
                } # End If $fixEnv
                # Get all services with vulnerability
                If (($ImagePath -like "* *") -and ($ImagePath -notLike '"*"*') -and ($ImagePath -like '*.exe*')) {
                    # Skip MsiExec.exe in uninstall strings
                    If ((($FixParameter.ParamName -eq 'UninstallString') -and ($ImagePath -NotMatch 'MsiExec(\.exe)?') -and ($ImagePath -Match '^((\w\:)|(%[-\w_()]+%))\\')) -or ($FixParameter.ParamName -eq 'ImagePath')) {
                        $NewPath = ($ImagePath -split ".exe ")[0]
                        $key = ($ImagePath -split ".exe ")[1]
                        $trigger = ($ImagePath -split ".exe ")[2]
                        $NewValue = ''
                        # Get service with vulnerability with key in ImagePath
                        If (-not ($trigger | Measure-Object).count -ge 1) {
                            If (($NewPath -like "* *") -and ($NewPath -notLike "*.exe")) {
                                $NewValue = "`"$NewPath.exe`" $key"
                            } # End If
                            # Get service with vulnerability with out key in ImagePath
                            ElseIf (($NewPath -like "* *") -and ($NewPath -like "*.exe")) {
                                $NewValue = "`"$NewPath`""
                            } # End ElseIf
                            If ((-not ([string]::IsNullOrEmpty($NewValue))) -and ($NewPath -like "* *")) {
                                try {
                                    $soft_service = $(if ($FixParameter.ParamName -Eq 'ImagePath') { 'Service' }Else { 'Software' })
                                    $OriginalPSPathOptimized = $OriginalPath.PSPath -replace $SpCharREGEX, '`$1'
                                    Write-Host "$(get-date -format u)  :  Old Value : $soft_service : '$($OriginalPath.PSChildName)' - $($OriginalPath.$($FixParameter.ParamName))"
                                    Write-Host "$(get-date -format u)  :  Expected  : $soft_service : '$($OriginalPath.PSChildName)' - $NewValue"
                                    if ($Passthru) {
                                        $PTElements += '' | Select-Object `
                                        @{n = 'Name'; e = { $OriginalPath.PSChildName } }, `
                                        @{n = 'Type'; e = { $soft_service } }, `
                                        @{n = 'ParamName'; e = { $FixParameter.ParamName } }, `
                                        @{n = 'Path'; e = { $OriginalPSPathOptimized } }, `
                                        @{n = 'OriginalValue'; e = { $OriginalPath.$($FixParameter.ParamName) } }, `
                                        @{n = 'ExpectedValue'; e = { $NewValue } }
                                    }
                                    If (! ($i -gt 2)) {
                                        Set-ItemProperty -Path $OriginalPSPathOptimized -Name $($FixParameter.ParamName) -Value $NewValue -ErrorAction Stop
                                        $DisplayName = ''
                                        $keyTmp = (Get-ItemProperty -Path $OriginalPSPathOptimized)
                                        If ($soft_service -match 'Software') {
                                            $DisplayName = $keyTmp.DisplayName
                                        }
                                        If ($keyTmp.$($FixParameter.ParamName) -eq $NewValue) {
                                            Write-Host "$(get-date -format u)  :  SUCCESS  : Path value was changed for $soft_service '$($OriginalPath.PSChildName)' $(if($DisplayName){"($DisplayName)"})"
                                        } # End If
                                        Else {
                                            Write-Host "$(get-date -format u)  :  ERROR  : Something is going wrong. Path was not changed for $soft_service '$(if($DisplayName){$DisplayName}else{$OriginalPath.PSChildName})'."
                                        } # End Else
                                    } # End If
                                } # End try
                                Catch {
                                    Write-Host "$(get-date -format u)  :  ERROR  : Something is going wrong. Value changing failed in service '$($OriginalPath.PSChildName)'."
                                    Write-Host "$(get-date -format u)  :  ERROR  : $_"
                                } # End Catch
                                Clear-Variable NewValue
                            } # End If
                        } # End Main If
                    } # End if (Skip not needed strings)
                } # End If
                If (($trigger | Measure-Object).count -ge 1) {
                    Write-Host "$(get-date -format u)  :  ERROR  : Can't parse  $($OriginalPath.$($FixParameter.ParamName)) in registry  $($OriginalPath.PSPath -replace 'Microsoft\.PowerShell\.Core\\Registry\:\:') "
                } # End If
            } # End Foreach
            }
} # End Job

#Windows Defender Configuration Files
New-Item -Path "C:\" -Name "Temp" -ItemType "directory" -Force | Out-Null; New-Item -Path "C:\temp\" -Name "Windows Defender" -ItemType "directory" -Force | Out-Null; Copy-Item -Path .\Files\"Windows Defender Configuration Files"\* -Destination "C:\temp\Windows Defender\" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

#Enable Windows Defender Exploit Protection
Set-ProcessMitigation -PolicyFilePath "C:\temp\Windows Defender\DOD_EP_V3.xml"

#Enable Windows Defender Application Control
Set-RuleOption -FilePath "C:\temp\Windows Defender\WDAC_V1_Recommended_Enforced.xml" -Option 0


#GPO Configurations
$gposdir = "$(Get-Location)\Files\GPOs"
Foreach ($gpocategory in Get-ChildItem "$(Get-Location)\Files\GPOs") {
    
    Foreach ($gpo in (Get-ChildItem "$(Get-Location)\Files\GPOs\$gpocategory")) {
        $gpopath = "$gposdir\$gpocategory\$gpo"
        .\Files\LGPO\LGPO.exe /g $gpopath
    }
}

Copy-Item .\files\auditing\auditbaseline.csv C:\temp\auditbaseline.csv 

#Clear Audit Policy
auditpol /clear /y

#Enforce the Audit Policy Baseline
auditpol /restore /file:C:\temp\auditbaseline.csv

#Confirm Changes
auditpol /list /user /v
auditpol.exe /get /category:*

Add-Type -AssemblyName PresentationFramework
$Answer = [System.Windows.MessageBox]::Show("Reboot to make changes effective?", "Restart Computer", "YesNo", "Question")
Switch ($Answer) {
    "Yes" { Write-Host "Performing Gpupdate"; Gpupdate /force /boot; Get-Job; Write-Warning "Restarting Computer in 15 Seconds"; Start-sleep -seconds 15; Restart-Computer -Force }
    "No" { Write-Host "Performing Gpupdate"; Gpupdate /force ; Get-Job; Write-Warning "A reboot is required for all changed to take effect" }
    Default { Write-Warning "A reboot is required for all changed to take effect" }
}

#DOT NET DOD HARDENING FORKED FROM SIMEON SECURITY
<#
Creating secure configuration Function. It needs to be called in the
two foreach loops as it has to touch every config file in each
.net framework version folder
#>
Function Set-SecureConfig {
    param (
        $VersionPath,
        $SecureMachineConfigPath
    )
    
    #Declaration and error prevention
    $SecureMachineConfig = $Null
    $MachineConfig = $Null
    [system.gc]::Collect() 
    
    #Getting Secure Machine.Configs
    $SecureMachineConfig = [xml](Get-Content $SecureMachineConfigPath)
        
    #Write-Host "Still using test path at $(Get-CurrentLine)"
    #$MachineConfigPath = "C:\Users\hiden\Desktop\NET-STIG-Script-master\Files\secure.machine - Copy.config"
    $MachineConfigPath = "$VersionPath"
    $MachineConfig = [xml](Get-Content $MachineConfigPath)
    #Ensureing file is closed
    [IO.File]::OpenWrite((Resolve-Path $MachineConfigPath).Path).close()

    <#Apply Machine.conf Configurations
    #Pulled XML assistance from https://stackoverflow.com/questions/9944885/powershell-xml-importnode-from-different-file
    #Pulled more XML details from http://www.maxtblog.com/2012/11/add-from-one-xml-data-to-another-existing-xml-file/
    #>
   
    # Do out. Automate each individual childnode for infinite nested. Currently only goes two deep
    $SecureChildNodes = $SecureMachineConfig.configuration | Get-Member | Where-Object MemberType -match "^Property" | Select-Object -ExpandProperty Name
    $MachineChildNodes = $MachineConfig.configuration | Get-Member | Where-Object MemberType -match "^Property" | Select-Object -ExpandProperty Name


    #Checking if each secure node is present in the XML file
    ForEach ($SecureChildNode in $SecureChildNodes) {
        #If it is not present, easy day. Add it in.
        If ($SecureChildNode -notin $MachineChildNodes) {
            #Adding node from the secure.machine.config file and appending it to the XML file
            $NewNode = $MachineConfig.ImportNode($SecureMachineConfig.configuration.$SecureChildNode, $true)
            $MachineConfig.DocumentElement.AppendChild($NewNode) | Out-Null
            #Saving changes to XML file
            $MachineConfig.Save($MachineConfigPath)
        }
        Elseif ($MachineConfig.configuration.$SecureChildNode -eq "") {
            #Turns out element sometimes is present but entirely empty. If that is the case we need to remove it
            # and add what we want         
            $MachineConfig.configuration.ChildNodes | Where-Object name -eq $SecureChildNode | ForEach-Object { $MachineConfig.configuration.RemoveChild($_) } | Out-Null
            $MachineConfig.Save($MachineConfigPath)
            #Adding node from the secure.machine.config file and appending it to the XML file            
            $NewNode = $MachineConfig.ImportNode($SecureMachineConfig.configuration.$SecureChildNode, $true)
            $MachineConfig.DocumentElement.AppendChild($NewNode) | Out-Null
            #Saving changes to XML file
            $MachineConfig.Save($MachineConfigPath)
        }
        Else {
            
            #If it is present... we have to check if the node contains the elements we want.
            #Going through each node in secure.machine.config for comparison
            $SecureElements = $SecureMachineConfig.configuration.$SecureChildNode | Get-Member | Where-Object MemberType -Match "^Property" | Where-object Name -notmatch "#comment" | Select-Object -Expandproperty Name        
            #Pull the Machine.config node and childnode and get the data properties for comparison
            $MachineElements = $MachineConfig.configuration.$SecureChildNode | Get-Member | Where-Object MemberType -Match "^Property" | Where-object Name -notmatch "#comment" | Select-Object -Expandproperty Name

            #I feel like there has got to be a better way to do this as we're three loops deep
            foreach ($SElement in $SecureElements) {
                #Comparing Element pulled earlier against Machine Elements.  If it's not present we will add it in
                If ($SElement -notin $MachineElements) {
                    #Adding in element that is not present
                    If ($SecureMachineConfig.configuration.$SecureChildNode.$SElement -NE "") {
                        $NewNode = $MachineConfig.ImportNode($SecureMachineConfig.configuration.$SecureChildNode.$SElement, $true)
                        $MachineConfig.configuration.$SecureChildNode.AppendChild($NewNode) | Out-Null
                        #Saving changes to XML file
                        $MachineConfig.Save($MachineConfigPath)
                    }
                    Else {
                        #This is for when the value declared is empty.
                        $NewNode = $MachineConfig.CreateElement("$SElement")                     
                        $MachineConfig.configuration.$SecureChildNode.AppendChild($NewNode) | Out-Null
                        #Saving changes to XML file
                        $MachineConfig.Save($MachineConfigPath)
                    }
                }
                Else {
                    $OldNode = $MachineConfig.SelectSingleNode("//$SElement")
                    $MachineConfig.configuration.$SecureChildNode.RemoveChild($OldNode) | Out-Null
                    $MachineConfig.Save($MachineConfigPath)
                    If ($SecureMachineConfig.configuration.$SecureChildNode.$SElement -EQ "") {
                        $NewElement = $MachineConfig.CreateElement("$SElement")
                        $MachineConfig.configuration.$SecureChildNode.AppendChild($NewElement) | Out-Null
                    }
                    Else {
                        $NewNode = $MachineConfig.ImportNode($SecureMachineConfig.configuration.$SecureChildNode.$SElement, $true)
                        $MachineConfig.configuration.$SecureChildNode.AppendChild($NewNode) | Out-Null
                    }
                
                    #Saving changes to XML file
                    $MachineConfig.Save($MachineConfigPath)               
                }#End else
            }#Foreach Element within SecureElements
        }#Else end for an if statement checking if the desired childnode is in the parent file
    }#End of iterating through SecureChildNodes
   
}


# .Net 32-Bit
ForEach ($DotNetVersion in (Get-ChildItem $netframework32 -Directory)) {
    #Starting .net exe/API to pass configuration Arguments
    If (Test-Path "$($DotNetVersion.FullName)\caspol.exe") {
        Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-q -f -pp on" -WindowStyle Hidden
        Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-m -lg" -WindowStyle Hidden 
        # Comment lines above and uncomment lines below to see output
        #Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-q -f -pp on" -NoNewWindow
        #Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-m -lg" -NoNewWindow
    }
    #Vul ID: V-30935	   	Rule ID: SV-40977r3_rule	   	STIG ID: APPNET0063
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\AllowStrongNameBypass") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -Value "0" -Force | Out-Null
    }
    Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\" -Name ".NETFramework" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -PropertyType "DWORD" -Value "0" -Force | Out-Null
    }
    #Vul ID: V-81495	   	Rule ID: SV-96209r2_rule	   	STIG ID: APPNET0075	
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$DotNetVersion\SchUseStrongCrypto") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$DotNetVersion\" -Name "SchUseStrongCrypto" -Value "1" -Force | Out-Null
    }
    Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework" -Name "$DotNetVersion" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$DotNetVersion\" -Name "SchUseStrongCrypto" -PropertyType "DWORD" -Value "1" -Force | Out-Null
    }

    <# Source for specifying configs for specific .Net versions
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/enforcefipspolicy-element (2.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/loadfromremotesources-element (4.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/netfx40-legacysecuritypolicy-element (4.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/etwenable-element (Doesn't specify. Assuming 3.0 or higher because it mentions Vista)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/network/defaultproxy-element-network-settings (Doesn't specify.)
    #>
    
    #Ensuring .net version has machine.config
    If (Test-Path "$($DotNetVersion.FullName)\Config\Machine.config") {
        #.net Version testing.
        If (($DotNetVersion -Split "v" )[1] -ge 2) {
            #.net version testing.
            If (($DotNetVersion -Split "v" )[1] -ge 4) {
                Write-Host ".Net version 4 or higher... Continuing with v4.0+ Machine.conf Merge..." -ForegroundColor White -BackgroundColor Black
                Set-SecureConfig -VersionPath "$($DotNetVersion.FullName)\Config\Machine.config" -SecureMachineConfigPath "$PSScriptRoot\Files\.Net Configuration Files\secure.machine-v4.config"
            }
            Else {
                Set-SecureConfig -VersionPath "$($DotNetVersion.FullName)\Config\Machine.config" -SecureMachineConfigPath "$PSScriptRoot\Files\.Net Configuration Files\secure.machine-v2.config"
            }
        }
        Else {
            Write-Host ".Net version is less than 2... Skipping Machine.conf Merge..." 
        }#End dotnet version test
    }
    Else {
        Write-Host "No Machine.Conf file exists for .Net version $DotNetVersion" 
    }#End testpath
}

# .Net 64-Bit
ForEach ($DotNetVersion in (Get-ChildItem $netframework64 -Directory)) {  
    #Starting .net exe/API to pass configuration Arguments
    If (Test-Path "$($DotNetVersion.FullName)\caspol.exe") {
        Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-q -f -pp on" -WindowStyle Hidden
        Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-m -lg" -WindowStyle Hidden 
        # Comment lines above and uncomment lines below to see output
        #Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-q -f -pp on" -NoNewWindow
        #Start-Process "$($DotNetVersion.FullName)\caspol.exe" -ArgumentList "-m -lg" -NoNewWindow
    }
    #Vul ID: V-30935	   	Rule ID: SV-40977r3_rule	   	STIG ID: APPNET0063
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\AllowStrongNameBypass") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -Value "0" -Force | Out-Null
    }
    Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\" -Name ".NETFramework" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -PropertyType "DWORD" -Value "0" -Force | Out-Null
    }
    #Vul ID: V-81495	   	Rule ID: SV-96209r2_rule	   	STIG ID: APPNET0075	
    If (Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$DotNetVersion\") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$DotNetVersion\" -Name "SchUseStrongCrypto" -Value "1" -Force | Out-Null
    }
    Else {
        New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\" -Name "$DotNetVersion" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$DotNetVersion\" -Name "SchUseStrongCrypto" -PropertyType "DWORD" -Value "1" -Force | Out-Null
    }

    <# Source for specifying configs for specific .Net versions
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/enforcefipspolicy-element (2.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/loadfromremotesources-element (4.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/netfx40-legacysecuritypolicy-element (4.0 or higher)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/etwenable-element (Doesn't specify. Assuming 3.0 or higher because it mentions Vista)
    https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/network/defaultproxy-element-network-settings (Doesn't specify.)
    #>
    
    #Ensuring current version has a machine.config to use
    If (Test-Path "$($DotNetVersion.FullName)\Config\Machine.config") {
        #version testing
        If (($DotNetVersion -Split "v" )[1] -ge 2) {
            #More version testing.
            If (($DotNetVersion -Split "v" )[1] -ge 4) {
                Set-SecureConfig -VersionPath "$($DotNetVersion.FullName)\Config\Machine.config" -SecureMachineConfigPath "$PSScriptRoot\Files\.Net Configuration Files\secure.machine-v4.config"
            }
            Else {
                Set-SecureConfig -VersionPath "$($DotNetVersion.FullName)\Config\Machine.config" -SecureMachineConfigPath "$PSScriptRoot\Files\.Net Configuration Files\secure.machine-v2.config"
            }
        }
        Else {
            Write-Host ".Net version is less than 2... Skipping Machine.conf Merge..." 
        }#End .net version test
    }
    Else {
        Write-Host "No Machine.Conf file exists for .Net version $DotNetVersion" 
    }#End testpath
}


