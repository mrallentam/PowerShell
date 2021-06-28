#Enterprise CA Configuration Step 2 
#Run this script on the Subordinate Issuing WebEnrollemnt Server

$domainnb="domain netbios name

#set Firewall rules
netsh int ipv4 set dynamicport tcp start=54445 num=555
netsh int ipv4 set dynamicport udp start=54445 num=555
netsh int ipv6 set dynamicport tcp start=54445 num=555
netsh int ipv6 set dynamicport udp start=54445 num=555

#install pspki
Install-Module -Name PSPKI -force

#Create CRT Publishing directory
New-Item -type directory -path c:\webenroll

#Create share and give access
New-SmbShare -Name "webenroll" -Path "webenroll" -FullAccess "eassfq\domain admins", "eassfq\Cert Publishers", "network service"
grant-smbshareaccess -name webenroll -accountname "anonymous logon" -accessright read
grant-smbshareaccess -name webenroll -accountname "everyone" -accessright read

#Give file permissions
$NewAcl = Get-Acl -Path "c:\webenroll"
# Set properties
$identity = "network service"
$fileSystemRights = "Full"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "c:\webenroll" -AclObject $NewAcl

$NewAcl = Get-Acl -Path "c:\webenroll"
# Set properties
$identity = "$domainsnb\domain admins"
$fileSystemRights = "Full"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "c:\webenroll" -AclObject $NewAcl

$NewAcl = Get-Acl -Path "c:\webenroll"
# Set properties
$identity = "$domainnb\cert publishers"
$fileSystemRights = "Full"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "c:\webenroll" -AclObject $NewAcl

$NewAcl = Get-Acl -Path "c:\webenroll"
# Set properties
$identity = "anonymous logon"
$fileSystemRights = "read"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "c:\webenroll" -AclObject $NewAcl

$NewAcl = Get-Acl -Path "c:\webenroll"
# Set properties
$identity = "everyone"
$fileSystemRights = "read"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "c:\webenroll" -AclObject $NewAcl

#Install webserver
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature
Import-Module WebAdministration

#create CRT Publishing Website
New-Website -Name "crt" -Port 80 -PhysicalPath c:\webenroll -ApplicationPool ".NET v4.5" -hostheader "crt.$domainnb.com"

#Enable Directory Browsing
appcmd.exe set config "crt" -section:system.webServer/directoryBrowse /enabled:"True" /showFlags:"Date, Time, Size, Extension"

#Create Virtual Directory under the CRT website
New-WebVirtualDirectory -Site "crt" -Name webenroll -PhysicalPath c:\webenroll

#Allow Anonymous Logon
Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/windowsAuthentication" -name enabled -value true -PSPath "IIS:\" -location crt
$pool=get-item "iis:\apppools\.net v4.5"
$pool.processModel.identityType = "NetworkService"
$pool | set-item

#Create New CRL Publishing Website
New-Website -Name "crl" -Port 80 -PhysicalPath c:\webenroll -ApplicationPool ".NET v4.5" -hostheader "crl.$domainnb.com"

#Enable Directory Browsing
appcmd.exe set config "crl" -section:system.webServer/directoryBrowse /enabled:"True" /showFlags:"Date, Time, Size, Extension"

#Create Virtual Directory under the CRL website
New-WebVirtualDirectory -Site "crl" -Name webenroll -PhysicalPath c:\webenroll

#Allow Anonymous Logon
Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/windowsAuthentication" -name enabled -value true -PSPath "IIS:\" -location crl

#App pool already set

