#Create Non-Privileged Account
$Password = "Enter Password Here"|ConvertTo-SecureString -AsPlainText -Force


$userProperties = @{

    Name                 = "Full Name"
    GivenName            = "First Name"
    Surname              = "Last Name"
    DisplayName          = "Display Name"
    Path                 = "OU=Users,OU=Resources,DC=yourdomain,DC=com"
    SamAccountName       = "firstame.Lastname-admin"
    UserPrincipalName    = "firstame.Lastname-admin@yourdomain.com"
    AccountPassword      = $Password
    PasswordNeverExpires = $True
    Enabled              = $True
    Description          = "Company Name Privileged Account"

}

New-ADUser @userProperties