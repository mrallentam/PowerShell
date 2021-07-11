##New Azure VM Infra with existing vnets

$VMLocalAdminUser = "localusername"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "ENTER PASSWORDHERE" -AsPlainText -Force
$LocationName = "ENTER LOCATION HERE"
$ResourceGroupName = "ENTER RESOURCE GROUP NAME HERE"
$ComputerName = "ENTER VM COMPUTENRNAME HERE"
$VMName = "ENTER AZURE VM NAME HERE SAME AS COMPUTERNAME"
$VMSize = "ENTER VMSIZE HERE"

$NetworkName = "ENTER NETWORK NAME HERE"
$NICName = "ENTER NIC NAME HERE"
$SubnetName = "ENTER SUBNET NAME HERE"
$SubnetAddressPrefix = "ENTER SUBNET PREFIX HERE"
$VnetAddressPrefix = "ENTER VNET PREFIX HERE"

$Vnet = get-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[2].Id

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose

