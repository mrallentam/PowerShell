#How to configure Azure AD PIM via PowerShell step by step 

#How to install Azure AD PIM

Install-Module -Name Microsoft.Azure.ActiveDirectory.PIM.PSModule

# How to get command

Get-Command -Module Microsoft.Azure.ActiveDirectory.PIM.PSModule

# How to check PIM Service connection

Show-PimServiceConnection

# How to check already defined assigement for that User

Get-PrivilegedRoleAssignment

# Define valibale based on PIM role

$roleAssignment = Get-PrivilegedRoleAssignment | Where {$_.RoleName -eq “Privileged Role Administrator”}

# Enable role assigement for sharepoint admin

Enable-PrivilegedRoleAssignment –Duration 1 –RoleAssignment $roleAssignment –Reason “Add SPOadmin to SPO Administrators”

# Check role assigment

Get-PrivilegedRoleAssignment

# How to disbale disabled assigment

Disable-PrivilegedRoleAssignment –RoleAssignment $roleAssignment

# Disconnect Powershell

Disconnect-PimService