import-module activedirectory
import-module hyper-v

cmdkey /add:%storagename%.file.core.windows.net /user:"storageaccountname\storageaccountname" /pass:%storagekey%

net use x: \\%storagename%.file.core.windows.net\data
 
$updroot = "f:\profiles"
$fslogixroot = "\\%storagename%.file.core.windows.net\data\fslogix\FSLogixProfiles"
$files = Get-ChildItem -Path $updroot -File -Filter UVHD-S*.vhdx | Sort Name

foreach ($file in $files){
$filename=($file).name
$sid=($file.Basename).Substring(5)
$sid2=($file.Basename).Substring(6)
$x=get-aduser -identity $sid 

$name = ($x).Name
$sam = ($x.SamAccountName).ToString()
$sid =($x).sid
        
$sourcevhdx = ($file).fullName
Mount-vhd -path $sourcevhdx 
$mountletter = (get-diskimage -imagePath $sourcevhdx| Get-Disk | Get-Partition|Get-Volume).DriveLetter
$mountpath = ($mountletter + ':\')  

$ProfileDir = 'Profile'
$vhdxprofiledir = Join-Path -Path $mountpath -ChildPath $ProfileDir

If (!(Test-Path $vhdxprofiledir)) {
Write-Output "Create Folder: $vhdxprofiledir"
New-Item $vhdxprofiledir -ItemType Directory | Out-Null
} 

$Excludes = @("Profile", "Uvhd-Binding", "`$RECYCLE.BIN", "System Volume Information")

$Content = Get-ChildItem $mountpath -Force
ForEach ($C in $Content) {
If ($Excludes -notcontains $C.Name) {
Write-Output ('Move: ' + $C.FullName)
Try { Move-Item $C.FullName -Destination $vhdxprofiledir -Force -ErrorAction Stop } 
Catch { Write-Warning "Error: $_" }
}
}

# Defining the registry file
$regtext = "Windows Registry Editor Version 5.00
`"ProfileImagePath`"=`"C:\\Users\\$SAM`"
`"Flags`"=dword:00000000
`"State`"=dword:00000000
`"ProfileLoadTimeLow`"=dword:00000000
`"ProfileLoadTimeHigh`"=dword:00000000
`"RefCount`"=dword:00000000
`"RunLogonScriptSync`"=dword:00000001
"

# Create the folder and registry file
Write-Output "Create Reg: $vhdxprofiledir\AppData\Local\FSLogix\ProfileData.reg"
If (!(Test-Path "$vhdxprofiledir\AppData\Local\FSLogix")) {
New-Item -Path "$vhdxprofiledir\AppData\Local\FSLogix" -ItemType directory | Out-Null
}
If (!(Test-Path "$vhdxprofiledir\AppData\Local\FSLogix\ProfileData.reg")) {
$regtext | Out-File "$vhdxprofiledir\AppData\Local\FSLogix\ProfileData.reg" -Encoding ascii
}


 # Dismount source VHDX
Dismount-DiskImage -ImagePath $sourcevhdx
# Small delay after dismounting the VHDX file to ensure it and the drive letter are free
Start-Sleep -Seconds 3

copy-item -Path $sourcevhdx -destination $fslogixroot

$Vhdxpath="x:\fslogix\FSLogixProfiles\$filename"

icacls $vhdxpath /setowner "eassfq\$sam" /T /C | Out-Null
icacls $vhdxpath /grant eassfq\$sam`:`(OI`)`(CI`)F /T | Out-Null
icacls $vhdxpath /grant eassfq\$sam`:`(OI`)`(CI`)F /T /inheritance:E | Out-Null
}

net use x: /delete
