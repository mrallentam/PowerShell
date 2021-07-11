#Install and configure adfs

#enter and replace the following variables
$domainuser = %$usernameonly% or %SAMAccountName%
$password = "%domain admin password"
$friendlyname = "%friendly name of certificate%"

#Install and configure ADFS 
$domain = $env:UserDnsDomain
$secpassword = ConvertTo-SecureString $password -AsPlainText -Force
$fqdn = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$filename = "C:\temp\$fdqn.pfx"
$user = "$domain\%domain admin user%"
$credential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $user, $secPassword

#install package provider
Install-PackageProvider nuget -force

#install PSPKI
Install-Module -Name PSPKI -Force

#import PSPKI
Import-Module -Name PSPKI

#create Self signed certificate

$selfSignedCert = New-SelfSignedCertificateEx `
    -Subject "CN=$fqdn" `
    -ProviderName "Microsoft Enhanced RSA and AES Cryptographic Provider" `
    -KeyLength 4096 -FriendlyName '$friendlyname' -SignatureAlgorithm sha512 `
    -EKU "Server Authentication", "Client authentication" `
    -KeyUsage "KeyEncipherment, DigitalSignature" `
    -Exportable -StoreLocation "LocalMachine"
$certThumbprint = $selfSignedCert.Thumbprint

#install and configure ADFS
Install-WindowsFeature -IncludeManagementTools -Name ADFS-Federation

Import-Module ADFS
Install-AdfsFarm -CertificateThumbprint $certThumbprint `
    -FederationServiceName $fqdn `
    -ServiceAccountCredential $credential

#Validate
Install-Module ADFSDiagnostics -Force
Import-Module ADFSDiagnostics -Force

Test-AdfsServerHealth | ft Name,Result -AutoSize




