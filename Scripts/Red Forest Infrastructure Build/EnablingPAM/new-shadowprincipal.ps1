$name=Read-host "Enter Name of Domain"
$dnsname=read-host "Enter FQDN of Domain"
$domaindn = "dc=domain,dc=redforest,dc=com" #distinguishedname of domain
$suffix="-Domain Admins"
$shadowsuffix= "$name"+"$suffix"
$ip=(resolve-dnsname $dnsname).ipaddress

# Get the SID for the domain Admins group of the existing forest
$ShadowPrincipalSid = (Get-ADGroup -Identity 'Domain Admins' -Properties ObjectSID -Server $ip[0].ObjectSID

# Container location
$Container = "CN=Shadow Principal Configuration,CN=Services,CN=Configuration,"+$domaindn

# Create the Shadow principal - note the type
New-ADObject -Type msDS-ShadowPrincipal -Name "$shadowsuffix" -Path $Container -OtherAttributes @{'msDS-ShadowPrincipalSid'= $ShadowPrincipalSid}
