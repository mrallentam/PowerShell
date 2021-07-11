#Create Privileged 
#disable administrator account if wanted
#take ad snapshot

#Fill in the blanks below and repeat for additional users
$Password = "Enter Password Here"|ConvertTo-SecureString -AsPlainText -Force

# Create a Privileged Account
$userProperties = @{

    Name                 = "Full Name"
    GivenName            = "First Name"
    Surname              = "Last Name"
    DisplayName          = "Display Name"
    Path                 = "OU=Privileged Users,OU=Resources,DC=yourdomain,DC=com"
    SamAccountName       = "firstame.Lastname-admin"
    UserPrincipalName    = "firstame.Lastname-admin@yourdomain.com"
    AccountPassword      = $Password
    PasswordNeverExpires = $True
    Enabled              = $True
    Description          = "Company Name Privileged Account"

}

New-ADUser @userProperties

# Add Privileged Account to EA, DA, & SA Groups
Add-ADGroupMember "Domain Admins" $userProperties.SamAccountName
Add-ADGroupMember "Enterprise Admins" $userProperties.SamAccountName
Add-ADGroupMember "Schema Admins" $userProperties.SamAccountName

<#
#Secure Administrator Account
Set-ADUser Administrator -AccountNotDelegated:$true -SmartcardLogonRequired:$true -Enabled:$false
#>

#Create Active Directory snapshot
C:\Windows\system32\ntdsutil.exe snapshot "activate instance ntds" create quit quit
 