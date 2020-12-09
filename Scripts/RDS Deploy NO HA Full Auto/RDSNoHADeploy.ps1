#RDS Build Orchestrator
#RDS Build no HA
#install rsat tools if it's not aleady installed
#search and replace "$Domain\$group" with actual domain\group  no quotes
#################################################################################################
#search and replace "$groupsid1" with actual groupsid_output  from below for group sid command no quotes
###Get RDS GroupNameSID copy output SID and paste this below
#$rdsgroupname="RDS group name only NO domain"
#$sid=(get-adgroup -identity $rdsgroupname).sid
#$groupsid=$sid|select-object value
#$groupsid     #<------Grab this output for $groupsid1
######################################################################################################
#search and replace "$nps1" with nps_fqdn no quotes
#search and replace "$sharedsecret1" with sharedsecret no quotes
#search and replace "$Web1a" with fqdn of web1 no quotes
#search and replace "$Web2a" with fqdn of web2 no quotes
#search and replace "$gate1" with fqdn of web1 no quotes
#search and replace "$gate2" with fqdn of web2 no quotes
#search and replace "$rdsusergroup1" with rds user group in domain\usergroup format no quotes

install-windowsfeature rsat -IncludeAllSubFeature

$credential=get-credential
import-module remotedesktopservices
import-module activedirectory


#Variables Fill in the information needed
$dnsdn="dns domain name"
$rdsusergroup="Active directory group created for rds users domain\groupname" 
$web1="Web/gateway server fqdn"
$web1ip="ipv4 of web/gateway1"
$web2="Web/gateway server fqdn"
$web2ip="{ipv4 address of web/gateway2"
$brkr1="broker server fqdn"
$rdsh1="Session host server fqdn"
$rdsh2="Session host server fqdn"
$gatewayfqdn="*****rd.domain.com*****"
$nps="fqdn of nps server"
$sharedsecret = "secret password for configuration of nps"
$dc="domain controller fqdn"
$credential=get-credential
$pfxpath="path to pfx certificate"
$pfxcreds=Get-Credential -UserName 'Enter password below' -Message 'Enter password below'
$profilediskpath="network share where user profiledisks will be shared"

#Adding Active Directory RDS group to local remote desktop users for rdsh servers
invoke-command -scriptblock {add-localgroupmember -group "Remote Desktop Users" -member "$rdsusergroup"} -computername $rdsh1
invoke-command -scriptblock {add-localgroupmember -group "Remote Desktop Users" -member "$rdsusergroup"} -computername $rdsh2

#Configure DNS Records
invoke-command -scriptblock {
Add-DnsServerResourceRecordA -Name "$gatewayfqdn" -ZoneName "$dnsdn" -AllowUpdateAny -IPv4Address "$web1ip" -TimeToLive 00:00:00
Add-DnsServerResourceRecordA -Name "$gatewayfqdn" -ZoneName "$dnsdn" -AllowUpdateAny -IPv4Address "$web2ip" -TimeToLive 00:00:00
} -computername $dc -credential $credential

#Deploy RDS
New-RDSessionDeployment -ConnectionBroker $brkr1 -SessionHost $rdsh1 -WebAccessServer $web1
Set-RDLicenseConfiguration -LicenseServer $brkr1 -Mode PerUser -ConnectionBroker $brkr1
add-rdserver -server $rdsh2 -role rds-rd-server -connectionbroker $brkr1
add-rdserver -server $web2 -role rds-web-access -connectionbroker $brkr1
add-rdsserver -server $web1 -role rds-gateway -connectionbroker $brkr1 -gatewayexternalfqdn $gatewayfqdn
add-rdsserver -server $web2 -role rds-gateway -connectionbroker $brkr1 -gatewayexternalfqdn $gatewayfqdn

#configure RDS
Set-RDDeploymentGatewayConfiguration -GatewayMode Custom -GatewayExternalFqdn $gatewayfqdn LogonMethod Password
Set-RDLicenseConfiguration -LicenseServer $brkr1 -Mode peruser -ConnectionBroker $brkr1 -Force
Set-RDCertificate -Role RDPublishing -ImportPath $pfxpath  -Password $pfxcreds.Password -ConnectionBroker $brkr1 -Force
Set-RDCertificate -Role RDRedirector -ImportPath $pfxpath -Password $pfxcreds.Password -ConnectionBroker $brkr1 -Force
Set-RDCertificate -Role RDWebAccess -ImportPath $pfxpath -Password $pfxcreds.Password -ConnectionBroker $brkr1 -Force
Set-RDCertificate -Role RDGateway -ImportPath $pfxpath  -Password $pfxcreds.Password -ConnectionBroker $brkr1 -Force


#configuring Gateway 1
invoke-command -scriptblock {
import-module remotedesktopservices
#Cleanout Default Installs
Remove-Item -Path "RDS:\GatewayServer\CAP\RDG_CAP_AllUsers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_RDConnectionBrokers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_AllDomainComputers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_HighAvailabilityBroker_DNS_RR" -Force -recurse
Remove-Item  -Path "RDS:\GatewayServer\GatewayManagedComputerGroups\RDG_RDCBComputers"-Force -recurse
Remove-Item  -Path "RDS:\GatewayServer\GatewayManagedComputerGroups\RDG_DNSRoundRobin"-Force -recurse

#Configure Central RDCap - You will be prompted for Secure Secret
Invoke-CimMethod -ClassName Win32_TSGatewayradiusserver -Namespace root\cimv2\terminalservices -methodname "add" -Arguments @{
name="$nps1";SharedSecret="$sharedsecret1"}
get-item -path "RDS:\GatewayServer\CentralCAPEnabled"|set-item -value 1
} -computername $web1

#Create RD_RAP
invoke-command -scriptblock {
$rdsusergroup="$Domain\$group"
function New-RdsGwRap {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,
        
        [String] $Description = [String]::Empty,
        
        [bool] $Enabled = $true,
        
        [ValidateSet('RG','CG','ALL')]
        [string] $ResourceGroupType = 'ALL',
        
        [string] $ResourceGroupName = [string]::Empty,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $UserGroupNames,
        
        [ValidateSet('3389','*')]
        [string] $PortNumbers = '3389'
    )
    
    $RapArgs = @{
        Name = $Name
        Description = $Description
        Enabled = $Enabled
        ResourceGroupType = $ResourceGroupType
        ResourceGroupName = $ResourceGroupName
        UserGroupNames = $UserGroupNames
        ProtocolNames = 'RDP'
        PortNumbers = $PortNumbers
    }
    try {
        $Invoke = Invoke-CimMethod -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayResourceAuthorizationPolicy -MethodName Create -Arguments $RapArgs
        if ($Invoke.ReturnValue -ne 0) {
            throw ('Failed creating RAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
        } else {
            Get-CimInstance -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayResourceAuthorizationPolicy -Filter ('Name = "{0}"' -f $Name)
        }
    } catch {
        Write-Error -ErrorRecord $_
    }
}
$name="RD_RAP"
new-rdsgwrap -name $name -usergroupnames "$rdsusergroup1"
} -computername $web1

#Config GW1 NPS 
invoke-command -scriptblock {
#configure Central NPS Server timeouts
netsh nps set remoteserver remoteservergroup = "TS GATEWAY SERVER GROUP" address = $nps1 timeout = 60 blackout = 60

#configure Gateway NPS RD_Cap Policy
netsh nps rename np name = "Connections to other access servers" newname = "RD_CAP"
netsh nps set np name = "rd_cap" state = "enable" 
netsh nps set np name = "rd_cap" processingorder = 2
netsh nps set np name = "rd_cap" policysource = 1
netsh nps set np name = "rd_cap" conditionid = "0x1fb5" conditiondata = "$GROUPSID1" 
netsh nps set np name = "rd_cap" profileid = "0x1005"      profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x100f"      profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x1009"      profiledata = "0x3" profiledata = "0x9" profiledata = "0x4" profiledata = "0xa" profiledata = "0x7"
netsh nps set np name = "rd_cap" profileid = "0x7"         profiledata = "0x1"
netsh nps set np name = "rd_cap" profileid = "0x6"         profiledata = "0x2"
} -computername $web1

#Create rdsgateway farm on gateway 1
invoke-command -scriptblock {
get-item RDS:\gatewayserver\GatewayFarm\Servers|new-item "RDS:\gatewayserver\GatewayFarm\Servers" -name $gate1
get-item RDS:\gatewayserver\GatewayFarm\Servers|new-item "RDS:\gatewayserver\GatewayFarm\Servers" -name $gate2
} -computername $web1


#configuring Gateway 2
invoke-command -scriptblock {
import-module remotedesktopservices
#Cleanout Default Installs
Remove-Item -Path "RDS:\GatewayServer\CAP\RDG_CAP_AllUsers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_RDConnectionBrokers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_AllDomainComputers" -Force -recurse
Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_HighAvailabilityBroker_DNS_RR" -Force -recurse
Remove-Item  -Path "RDS:\GatewayServer\GatewayManagedComputerGroups\RDG_RDCBComputers"-Force -recurse
Remove-Item  -Path "RDS:\GatewayServer\GatewayManagedComputerGroups\RDG_DNSRoundRobin"-Force -recurse

#Configure Central RDCap - You will be prompted for Secure Secret
Invoke-CimMethod -ClassName Win32_TSGatewayradiusserver -Namespace root\cimv2\terminalservices -methodname "add" -Arguments @{
name="$nps1";SharedSecret="$sharedsecret1"}
get-item -path "RDS:\GatewayServer\CentralCAPEnabled"|set-item -value 1
} -computername $web2

#Create RD_RAP
invoke-command -scriptblock {
$rdsusergroup="$Domain\$group"
function New-RdsGwRap {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,
        
        [String] $Description = [String]::Empty,
        
        [bool] $Enabled = $true,
        
        [ValidateSet('RG','CG','ALL')]
        [string] $ResourceGroupType = 'ALL',
        
        [string] $ResourceGroupName = [string]::Empty,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $UserGroupNames,
        
        [ValidateSet('3389','*')]
        [string] $PortNumbers = '3389'
    )
    
    $RapArgs = @{
        Name = $Name
        Description = $Description
        Enabled = $Enabled
        ResourceGroupType = $ResourceGroupType
        ResourceGroupName = $ResourceGroupName
        UserGroupNames = $UserGroupNames
        ProtocolNames = 'RDP'
        PortNumbers = $PortNumbers
    }
    try {
        $Invoke = Invoke-CimMethod -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayResourceAuthorizationPolicy -MethodName Create -Arguments $RapArgs
        if ($Invoke.ReturnValue -ne 0) {
            throw ('Failed creating RAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
        } else {
            Get-CimInstance -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayResourceAuthorizationPolicy -Filter ('Name = "{0}"' -f $Name)
        }
    } catch {
        Write-Error -ErrorRecord $_
    }
}
$name="RD_RAP"
new-rdsgwrap -name $name -usergroupnames $rdsusergroup1
} -computername $web2

#Config GW1 NPS 
invoke-command -scriptblock {
#configure Central NPS Server timeouts
netsh nps set remoteserver remoteservergroup = "TS GATEWAY SERVER GROUP" address = $nps1 timeout = 60 blackout = 60

#configure Gateway NPS RD_Cap Policy
netsh nps rename np name = "Connections to other access servers" newname = "RD_CAP"
netsh nps set np name = "rd_cap" state = "enable" 
netsh nps set np name = "rd_cap" processingorder = 2
netsh nps set np name = "rd_cap" policysource = 1
netsh nps set np name = "rd_cap" conditionid = "0x1fb5" conditiondata = "$GROUPSID1" 
netsh nps set np name = "rd_cap" profileid = "0x1005"      profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x100f"      profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x1009"      profiledata = "0x3" profiledata = "0x9" profiledata = "0x4" profiledata = "0xa" profiledata = "0x7"
netsh nps set np name = "rd_cap" profileid = "0x7"         profiledata = "0x1"
netsh nps set np name = "rd_cap" profileid = "0x6"         profiledata = "0x2"
} -computername $web2

#Create rdsgateway farm on gateway 2
invoke-command -scriptblock {
get-item RDS:\gatewayserver\GatewayFarm\Servers|new-item "RDS:\gatewayserver\GatewayFarm\Servers" -name $gate1
get-item RDS:\gatewayserver\GatewayFarm\Servers|new-item "RDS:\gatewayserver\GatewayFarm\Servers" -name $gate2
} -computername $web2

#Configure NPS
invoke-command -scriptblock {
$sharedsecret = "$sharedsecret1"
#configure incoming NPS clients
netsh nps add name = gateway1 client address = $web1a state = ENABLE sharedsecret = $sharedsecret requireauthattrib = NO vendor = "RADIUS Standard"
netsh nps add name = gateway2 client address = $web2a state = ENABLE sharedsecret = $sharedsecret requireauthattrib = NO vendor = "RADIUS Standard"
} -computername $nps

#Create NPS RD_Cap Policy
invoke-command -scriptblock {
netsh nps rename np name = "Connections to other access servers" newname = "RD_CAP"
netsh nps set np name = "rd_cap" state = "enable" 
netsh nps set np name = "rd_cap" processingorder = 2
netsh nps set np name = "rd_cap" policysource = 1
netsh nps set np name = "rd_cap" conditionid = "0x1023" conditiondata = "$groupsid1" 
netsh nps set np name = "rd_cap" profileid = "0x1005" profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x100f" profiledata = "TRUE"
netsh nps set np name = "rd_cap" profileid = "0x1009" profiledata = "0x3" profiledata = "0x9" profiledata = "0x4" profiledata = "0xa" profiledata = "0x7"
netsh nps set np name = "rd_cap" profileid = "0x7" profiledata = "0x1"
netsh nps set np name = "rd_cap" profileid = "0x6" profiledata = "0x2"
netsh nps set np name = "rd_cap" profileid = "0xffffffaa" profiledata = "0x32"
netsh nps set np name = "rd_cap" profileid = "0xffffffa9" profiledata = "0x78"
} -computername $nps


#create RDS Collection
New-RDSessionCollection -collectionname "Red Forest" -ConnectionBroker $brkr1 -SessionHost @($rdsh1, $rdsh2) 
Set-RDSessionCollectionConfiguration -CollectionName "Red Forest" -UserGroup "$rdsusergroup"
Set-RDSessionCollectionConfiguration -CollectionName "Red Forest" -TemporaryFoldersDeletedOnExit $true -AutomaticReconnectionEnabled $true -ActiveSessionLimitMin 720 -DisconnectedSessionLimitMin 60 -IdleSessionLimitMin 60
Set-RDSessionCollectionConfiguration -CollectionName "Red Forest" -SecurityLayer 2 -EncryptionLevel 2 -AuthenticateUsingNLA $true
Set-RDSessionCollectionConfiguration -CollectionName "Red Forest" -ClientDeviceRedirectionOptions 0x0020 -MaxRedirectedMonitors 4
Set-RDSessionCollectionConfiguration -CollectionName "Red Forest" -EnableUserProfileDisk $true -DiskPath $profilediskpath -MaxUserProfileDiskSizeGB 20

#RDS Tuneup and Reboot
$computers = "$web1","$web2","$brkr1","$rdsh1","$rdsh2","$nps"
foreach ($computer in $computers){
invoke-command -scriptblock {
netsh interface tcp set global autotuninglevel=highlyrestricted
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 0x20 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" /v fClientDisableUDP /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\SystemCertificates\AuthRoot" /v DisableRootAutoUpdate /t Reg_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableTaskOffload /t REG_DWORD /d 1 /f
shutdown /r /f /t 0
} -computername $computer
}




