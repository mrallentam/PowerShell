
# Import module
import-module Az
import-module AzureAD

# Set Parameters
$RGName = "%resource group name%"                      # Resouce Group Name
$RGLocation = "%location%"               # Resouce Group Location
$HPName = "%hostpool name%"                # Host Pool Name
$HPDescription = "%Description of Hostpool%"          # Host Pool Description
$HPFriendlyName = "%Hostpool Friendly name%"        # Host Pool Friendly Name
$MaxSessionLimit = "%Number of Sessions%"                  # Max Session Limit
$AGName = "%Application Group Name%"           # Application Group Name
$AGDescription = "%Application Group Description%"          # Application Group Description
$AGFriendlyName = "%Application Group Friendly Name%"        # Application Group Friendly Name
$WSName = "%WorkSpaceName%"               # WorkSpace Name
$WSDescription = "Workspace Description"          # WorkSpace Description
$WSFriendlyName = "WorkSpaceFriendlyName"        # WorkSpace Friendly Name
$WVDLocation = "%WVD Location%"                 # WVD Location
$ConnectUser = "%account to add computers to domain%"       # Azure and AzureAD for resource creation account
$WVDGroupName = "%User group to use WVD%"              # WVD usage group

# Create credential
$password = ConvertTo-SecureString -String "%Special Password%" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential $ConnectUser, $password

$creds=get-credential

# Connect Azure
Connect-azaccount
#or
connect-azaccount -UseDeviceAuthentication

# Connect AzureAD
Connect-AzureAD -Credential $credential

#or
#connect-azuread


# Create ResouceGroup IF New resourcegroup is needed.
New-AzResourceGroup -Name $RGName -Location $RGLocation

# Create WVD HostPool
New-AzWvdHostPool  -ResourceGroupName $RGName `
                                -Name $HPName `
                                -Location $WVDLocation `
                                -PreferredAppGroupType 'Desktop' `
                                -HostPoolType 'Pooled' `
                                -LoadBalancerType 'BreadthFirst' `
                                -RegistrationTokenOperation 'Update' `
                                -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) `
                                -Description $HPDescription `
                                -FriendlyName $HPFriendlyName `
                                -MaxSessionLimit $MaxSessionLimit `
                                -VMTemplate $null `
                                -CustomRdpProperty $null `
                                -Ring $null `
                                -ValidationEnvironment:$false


# Get WVD HostPool ID
$HPPath = Get-AzWvdHostPool -Name $HPName -ResourceGroupName $RGName

# Create WVD Application Group
New-AzWvdApplicationGroup -ResourceGroupName $RGName `
                            -Name $AGName `
                            -Location $WVDLocation `
                            -FriendlyName $AGFriendlyName `
                            -Description $AGDescription `
                            -HostPoolArmPath $HPPath.Id `
                            -ApplicationGroupType 'Desktop'


# Get WVD Application Group ID
$APPath = Get-AzWvdApplicationGroup -Name $AGName -ResourceGroupName $RGName

New-AzWvdWorkspace -ResourceGroupName $RGName `
                        -Name $WSName `
                        -Location $WVDLocation `
                        -FriendlyName $WSFriendlyName `
                        -ApplicationGroupReference $null `
                        -Description $WSDescription


# Add WVD Application Group to WorkSpace
Register-AzWvdApplicationGroup -ResourceGroupName $RGName `
                                    -WorkspaceName $WSName `
                                    -ApplicationGroupPath $APPath.Id

# Grant permissions to WVD
$WVDUsersGroup = Get-AzureADGroup -SearchString $WVDGroupName
New-AzRoleAssignment -ObjectId $WVDUsersGroup.ObjectID -RoleDefinitionName "Desktop Virtualization User" -ResourceName $AGName -ResourceGroupName $RGName -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups'


Read-host -prompt "Add host to new host pool"

