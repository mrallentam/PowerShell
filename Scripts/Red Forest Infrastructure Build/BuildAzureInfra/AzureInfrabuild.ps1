#Azure infra build from scratch
# Creates 	- Resource Group
# 			- LogAnalyticsWorkspace
#			- 1 vnet  	 /24
#			- 8 submets  /27
#			- 2x Windows Core Domain controllers
#			- 6x TBD machines
#######################################################################


$rgname = 'Enter Resource Groupname here'
$location = 'Enter Location here'
$loganalyticswsname="Enter Log analytics name here"
$subnetname1='enter subnetname 1 here'
$subnetname2='enter subnetname 2 here'
$subnetname3='enter subnetname 3 here'
$subnetname4='enter subnetname 4 here'
$subnetname5='enter subnetname 5 here'
$subnetname6='enter subnetname 6 here'
$subnetname7='enter subnetname 7 here'
$subnetname8='enter subnetname 8 here'
$subnet1prefix='192.168.100.0/27'
$subnet2prefix='192.168.100.32/27'
$subnet3prefix='192.168.100.64/27'
$subnet4prefix='192.168.100.96/27'
$subnet5prefix='192.168.100.128/27'
$subnet6prefix='192.168.100.160/27'
$subnet7prefix='192.168.100.192/27'
$subnet8prefix='192.168.100.224/27'
$nsg1name="enter nsg1 name"
$nsg2name="enter nsg2 name"
$nsg3name="enter nsg3 name"
$nsg4name="enter nsg4 name"
$nsg5name="enter nsg5 name"
$nsg6name="enter nsg6 name"
$nsg7name="enter nsg7 name"
$nsg8name="enter nsg8 name"
$rdpprefix="enter external rdp address here"
$vnetname = "enter vnetname here"
$vnetprefix="192.168.100.0/24"
$dns1="192.168.100.100"
$dns2="192.168.100.101"

###vm admin login info
$VMLocalAdminUser = "enter localusername"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "ENTER PASSWORDHERE" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)


##vm1 (DC1)
$ComputerName1 = "ENTER VM COMPUTENRNAME HERE"
$VMName1 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize1 = "Standard_B2ms"
$NICName1 = "ENTER NIC NAME HERE"
$ip1="192.168.100.100"
$vm1dns1= "127.0.0.1"
$vm1dns2=  "192.169.100.101"

##vm2 (DC 2)
$ComputerName2 = "ENTER VM COMPUTENRNAME HERE"
$VMName2 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize2 = "Standard_B2ms"
$NICName2 = "ENTER NIC NAME HERE"
$ip2="192.168.100.101"
$vm2dns1= "192.168.100.100"
$vm2dns2= "192.168.100.101"

##vm3
$ComputerName3 = "ENTER VM COMPUTENRNAME HERE"
$VMName3 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize3 = "Standard_B2ms"
$NICName3 = "ENTER NIC NAME HERE"
$ip3="vm3 ipaddress"

##vm4
$ComputerName4 = "ENTER VM COMPUTENRNAME HERE"
$VMName4 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize4 = "Standard_B2ms"
$NICName4 = "ENTER NIC NAME HERE"
$ip4="vm4 ipaddress"

##vm5
$ComputerName5 = "ENTER VM COMPUTENRNAME HERE"
$VMName5 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize5 = "Standard_B2ms"
$NICName5 = "ENTER NIC NAME HERE"
$ip5="vm5 ipaddress"


##vm6
$ComputerName6 = "ENTER VM COMPUTENRNAME HERE"
$VMName6 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize6 = "Standard_B2ms"
$NICName6 = "ENTER NIC NAME HERE"
$ip="vm6 ipaddress"

##vm7
$ComputerName7 = "ENTER VM COMPUTENRNAME HERE"
$VMName7 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize7 = "Standard_B2ms"
$NICName7 = "ENTER NIC NAME HERE"
$ip7="vm7 ipaddress"

##vm8
$ComputerName8 = "ENTER VM COMPUTENRNAME HERE"
$VMName8 = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize8 = "Standard_B2ms"
$NICName8 = "ENTER NIC NAME HERE"
$ip8="vm8 ipaddress"


#create resourcegroup
new-azresourcegroup -name $rgname -location $location

#create log analytics workspace
New-AzOperationalInsightsWorkspace -Location $Location -Name $loganalyticswsname -Sku Standard -ResourceGroupName $rgname

#create new virtual network
$subnet1=New-AzVirtualNetworkSubnetConfig -Name $subnetname1 -AddressPrefix $subnet1prefix
$subnet2=New-AzVirtualNetworkSubnetConfig -Name $subnetname2 -AddressPrefix $subnet2prefix
$subnet3=New-AzVirtualNetworkSubnetConfig -Name $subnetname3 -AddressPrefix $subnet3prefix
$subnet4=New-AzVirtualNetworkSubnetConfig -Name $subnetname4 -AddressPrefix $subnet4prefix
$subnet5=New-AzVirtualNetworkSubnetConfig -Name $subnetname5 -AddressPrefix $subnet5prefix
$subnet6=New-AzVirtualNetworkSubnetConfig -Name $subnetname6 -AddressPrefix $subnet6prefix
$subnet7=New-AzVirtualNetworkSubnetConfig -Name $subnetname7 -AddressPrefix $subnet7prefix
$subnet8=New-AzVirtualNetworkSubnetConfig -Name $subnetname8 -AddressPrefix $subnet8prefix
$virtualnetwork=New-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgname -Location $location -AddressPrefix $vnetprefix -Subnet $subnet1, $subnet2, $subnet3, $subnet4, $subnet5, $subnet6, $subnet7, $subnet8

#create nsgs
$nsg1rule1=New-AzNetworkSecurityRuleConfig -Name Vnetin -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet1prefix -DestinationPortRange *
$nsg1rule2=New-AzNetworkSecurityRuleConfig -Name RDPIN -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet1prefix -DestinationPortRange 3389
$nsg1rule3=New-AzNetworkSecurityRuleConfig -Name Vnetout -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet1prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg2rule1=New-AzNetworkSecurityRuleConfig -Name Vnetinbound -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet2prefix -DestinationPortRange *
$nsg2rule2=New-AzNetworkSecurityRuleConfig -Name RDPINBOUND -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet2prefix -DestinationPortRange 3389
$nsg2rule3=New-AzNetworkSecurityRuleConfig -Name Vnetoutbound -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet2prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg3rule1=New-AzNetworkSecurityRuleConfig -Name localvnetin -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet3prefix -DestinationPortRange *
$nsg3rule2=New-AzNetworkSecurityRuleConfig -Name inrdp -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet3prefix -DestinationPortRange 3389
$nsg3rule3=New-AzNetworkSecurityRuleConfig -Name localVnetout -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet3prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg4rule1=New-AzNetworkSecurityRuleConfig -Name localnetinbound -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet4prefix -DestinationPortRange *
$nsg4rule2=New-AzNetworkSecurityRuleConfig -Name InboundRDP -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet4prefix -DestinationPortRange 3389
$nsg4rule3=New-AzNetworkSecurityRuleConfig -Name localVnetoutbound -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet4prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg5rule1=New-AzNetworkSecurityRuleConfig -Name Vnetin -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet5prefix -DestinationPortRange *
$nsg5rule2=New-AzNetworkSecurityRuleConfig -Name RDPIN -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet5prefix -DestinationPortRange 3389
$nsg5rule3=New-AzNetworkSecurityRuleConfig -Name Vnetout -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet5prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg6rule1=New-AzNetworkSecurityRuleConfig -Name Vnetinbound -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet6prefix -DestinationPortRange *
$nsg6rule2=New-AzNetworkSecurityRuleConfig -Name RDPINBOUND -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet6prefix -DestinationPortRange 3389
$nsg6rule3=New-AzNetworkSecurityRuleConfig -Name Vnetoutbound -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet6prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg7rule1=New-AzNetworkSecurityRuleConfig -Name localvnetin -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet7prefix -DestinationPortRange *
$nsg7rule2=New-AzNetworkSecurityRuleConfig -Name inrdp -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet7prefix -DestinationPortRange 3389
$nsg7rule3=New-AzNetworkSecurityRuleConfig -Name localVnetout -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet7prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$nsg8rule1=New-AzNetworkSecurityRuleConfig -Name localnetinbound -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix $vnetprefix -SourcePortRange * -DestinationAddressPrefix $subnet8prefix -DestinationPortRange *
$nsg8rule2=New-AzNetworkSecurityRuleConfig -Name InboundRDP -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix $rdpprefix -SourcePortRange * -DestinationAddressPrefix $subnet8prefix -DestinationPortRange 3389
$nsg8rule3=New-AzNetworkSecurityRuleConfig -Name localVnetoutbound -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix $subnet8prefix -SourcePortRange * -DestinationAddressPrefix $vnetprefix -DestinationPortRange *

$networkSecurityGroup1 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg1name -SecurityRules $nsg1rule1, $nsg1rule2, $nsg1rule3

$networkSecurityGroup2 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg2name -SecurityRules $nsg2rule1, $nsg2rule2, $nsg2rule3

$networkSecurityGroup3 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg3name -SecurityRules $nsg3rule1, $nsg3rule2, $nsg3rule3

$networkSecurityGroup4 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg4name -SecurityRules $nsg4rule1, $nsg4rule2, $nsg4rule3

$networkSecurityGroup5 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg5name -SecurityRules $nsg5rule1, $nsg5rule2, $nsg5rule3

$networkSecurityGroup6 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg6name -SecurityRules $nsg6rule1, $nsg6rule2, $nsg6rule3

$networkSecurityGroup7 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg7name -SecurityRules $nsg7rule1, $nsg7rule2, $nsg7rule3

$networkSecurityGroup8 = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $location -Name $nsg8name -SecurityRules $nsg8rule1, $nsg8rule2, $nsg8rule3


#Associate NSG to subnets
$vnet1=get-azvirtualnetwork -resourcegroupname $rgname -name $vnetname

$sub1=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname1
$sub2=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname2
$sub3=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname3
$sub4=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname4
$sub5=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname5
$sub6=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname6
$sub7=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname7
$sub8=get-azvirtualnetworksubnetconfig -virtualnetwork $vnet1 -name $subnetname8


set-AzVirtualNetworkSubnetConfig -Name $sub1.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup1.id -addressprefix $sub1.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub2.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup2.id -addressprefix $sub2.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub3.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup3.id -addressprefix $sub3.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub4.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup4.id -addressprefix $sub4.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub5.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup5.id -addressprefix $sub5.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub6.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup6.id -addressprefix $sub6.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub7.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup7.id -addressprefix $sub7.addressprefix
set-AzVirtualNetworkSubnetConfig -Name $sub8.name -VirtualNetwork $vnet1 -NetworkSecurityGroupId $networksecuritygroup8.id -addressprefix $sub8.addressprefix


#create vms
$NIC1 = New-AzNetworkInterface -Name $NICName1 -ResourceGroupName $rgname -Location $Location -SubnetId $sub4.id
$VirtualMachine1 = New-AzVMConfig -VMName $VMName1 -VMSize $VMSize1
$VirtualMachine1 = Set-AzVMOperatingSystem -VM $VirtualMachine1 -Windows -ComputerName $ComputerName1 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine1 = Add-AzVMNetworkInterface -VM $VirtualMachine1 -Id $NIC1.Id
$VirtualMachine1 = Set-AzVMSourceImage -VM $VirtualMachine1 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

$NIC2 = New-AzNetworkInterface -Name $NICName2 -ResourceGroupName $rgname -Location $Location -SubnetId $sub4.id
$VirtualMachine2 = New-AzVMConfig -VMName $VMName2 -VMSize $VMSize2
$VirtualMachine2 = Set-AzVMOperatingSystem -VM $VirtualMachine2 -Windows -ComputerName $ComputerName2 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine2 = Add-AzVMNetworkInterface -VM $VirtualMachine2 -Id $NIC2.Id
$VirtualMachine2 = Set-AzVMSourceImage -VM $VirtualMachine2 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

$NIC3 = New-AzNetworkInterface -Name $NICName3 -ResourceGroupName $rgname -Location $Location -SubnetId $sub2.id
$VirtualMachine3 = New-AzVMConfig -VMName $VMName3 -VMSize $VMSize3
$VirtualMachine3 = Set-AzVMOperatingSystem -VM $VirtualMachine3 -Windows -ComputerName $ComputerName3 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine3 = Add-AzVMNetworkInterface -VM $VirtualMachine3 -Id $NIC3.Id
$VirtualMachine3 = Set-AzVMSourceImage -VM $VirtualMachine3 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

$NIC4 = New-AzNetworkInterface -Name $NICName4 -ResourceGroupName $rgname -Location $Location -SubnetId $sub2.id
$VirtualMachine4 = New-AzVMConfig -VMName $VMName4 -VMSize $VMSize4
$VirtualMachine4 = Set-AzVMOperatingSystem -VM $VirtualMachine4 -Windows -ComputerName $ComputerName4 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine4 = Add-AzVMNetworkInterface -VM $VirtualMachine4 -Id $NIC4.Id
$VirtualMachine4 = Set-AzVMSourceImage -VM $VirtualMachine1 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

#create vms
$NIC5 = New-AzNetworkInterface -Name $NICName5 -ResourceGroupName $rgname -Location $Location -SubnetId $sub2.id
$VirtualMachine5 = New-AzVMConfig -VMName $VMName5 -VMSize $VMSize5
$VirtualMachine5 = Set-AzVMOperatingSystem -VM $VirtualMachine1 -Windows -ComputerName $ComputerName5 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine5 = Add-AzVMNetworkInterface -VM $VirtualMachine5 -Id $NIC5.Id
$VirtualMachine5 = Set-AzVMSourceImage -VM $VirtualMachine5 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

$NIC6 = New-AzNetworkInterface -Name $NICName6 -ResourceGroupName $rgname -Location $Location -SubnetId $sub4.id
$VirtualMachine6 = New-AzVMConfig -VMName $VMName6 -VMSize $VMSize6
$VirtualMachine6 = Set-AzVMOperatingSystem -VM $VirtualMachine6 -Windows -ComputerName $ComputerName6 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine6 = Add-AzVMNetworkInterface -VM $VirtualMachine6 -Id $NIC6.Id
$VirtualMachine6 = Set-AzVMSourceImage -VM $VirtualMachine6 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

$NIC7 = New-AzNetworkInterface -Name $NICName7 -ResourceGroupName $rgname -Location $Location -SubnetId $sub2.id
$VirtualMachine7 = New-AzVMConfig -VMName $VMName7 -VMSize $VMSize7
$VirtualMachine7 = Set-AzVMOperatingSystem -VM $VirtualMachine7 -Windows -ComputerName $ComputerName7 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine7 = Add-AzVMNetworkInterface -VM $VirtualMachine7 -Id $NIC7.Id
$VirtualMachine7 = Set-AzVMSourceImage -VM $VirtualMachine7 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

$NIC8 = New-AzNetworkInterface -Name $NICName8 -ResourceGroupName $rgname -Location $Location -SubnetId $sub2.id
$VirtualMachine8 = New-AzVMConfig -VMName $VMName8 -VMSize $VMSize8
$VirtualMachine8 = Set-AzVMOperatingSystem -VM $VirtualMachine8 -Windows -ComputerName $ComputerName8 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine8 = Add-AzVMNetworkInterface -VM $VirtualMachine8 -Id $NIC8.Id
$VirtualMachine8 = Set-AzVMSourceImage -VM $VirtualMachine1 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest


New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine1 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine2 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine3 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine4 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine5 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine6 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine7 -Verbose

New-AzVM -ResourceGroupName $rgname -Location $Location -VM $VirtualMachine8 -Verbose

#Disable boot diagnostics
$vm1 = Get-AzVM -Name $VMName1
Set-AzVMBootDiagnostic -VM $vm1 -Disable

$vm2 = Get-AzVM -Name $VMName2
Set-AzVMBootDiagnostic -VM $vm2 -Disable

$vm3 = Get-AzVM -Name $VMName3
Set-AzVMBootDiagnostic -VM $vm3 -Disable

$vm4 = Get-AzVM -Name $VMName4
Set-AzVMBootDiagnostic -VM $vm4 -Disable

$vm5 = Get-AzVM -Name $VMName5
Set-AzVMBootDiagnostic -VM $vm5 -Disable

$vm6 = Get-AzVM -Name $VMName6
Set-AzVMBootDiagnostic -VM $vm6 -Disable

$vm7 = Get-AzVM -Name $VMName7
Set-AzVMBootDiagnostic -VM $vm7 -Disable

$vm8 = Get-AzVM -Name $VMName8
Set-AzVMBootDiagnostic -VM $vm8 -Disable


$Nic1 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname1
$Nic1.IpConfigurations[0].PrivateIpAddress = "$ip1"
$Nic1.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic1.DnsSettings.DnsServers.Add("$vm1dns1")
$nic1.DnsSettings.DnsServers.Add("$vm1dns2")
Set-AzNetworkInterface -NetworkInterface $Nic1


$Nic2 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname2
$Nic2.IpConfigurations[0].PrivateIpAddress = "$ip2"
$Nic2.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic2.DnsSettings.DnsServers.Add("$vm2dns1")
$nic2.DnsSettings.DnsServers.Add("$vm2dns2")
Set-AzNetworkInterface -NetworkInterface $Nic2


$Nic3 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname3
$Nic3.IpConfigurations[0].PrivateIpAddress = "$ip3"
$Nic3.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic3.DnsSettings.DnsServers.Add("$dns1")
$nic3.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic3


$Nic4 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname4
$Nic4.IpConfigurations[0].PrivateIpAddress = "$ip4"
$Nic4.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic4.DnsSettings.DnsServers.Add("$dns1")
$nic4.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic4

$Nic5 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname5
$Nic5.IpConfigurations[0].PrivateIpAddress = $ip5
$Nic5.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic5.DnsSettings.DnsServers.Add("$dns1")
$nic5.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic5


$Nic6 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname6
$Nic6.IpConfigurations[0].PrivateIpAddress = "$ip6"
$Nic6.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic6.DnsSettings.DnsServers.Add("$dns1")
$nic6.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic6


$Nic7 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname7
$Nic7.IpConfigurations[0].PrivateIpAddress = "$ip7"
$Nic7.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic7.DnsSettings.DnsServers.Add("$dns1")
$nic7.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic7


$Nic8 = Get-AzNetworkInterface -ResourceGroupName $rgname -Name $nicname8
$Nic8.IpConfigurations[0].PrivateIpAddress = "$ip8"
$Nic8.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic8.DnsSettings.DnsServers.Add("$dns1")
$nic8.DnsSettings.DnsServers.Add("$dns2")
Set-AzNetworkInterface -NetworkInterface $Nic8



