
function update-csccfiles {
$exp=".\cscc.exe --update"

	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
    invoke-expression -command $exp

}

Function set-csccprofile {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$profile
	#also benchmarkID

	)
	$exp1=".\cscc.exe --setProfile $profile" 
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	invoke-expression -command '$exp1'
	
}
Function set-csccallprofiles {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$profile
	#also benchmarkID

	)
	$exp2=".\cscc.exe --setProfileAll $profile"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	invoke-expression -command $exp2
}

Function enable-csccall {
   
	$exp3=".\cscc.exe -ea"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	invoke-expression -command $exp3
}

Function disable-csccall {
   	$exp4=".\cscc --da  $profile"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp4	
}

Function uninstall-csccall {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

	)

   	$exp5=".\cscc.exe -ua"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp5	 
}

Function Get-cscccontentupdates {
   
 [CmdletBinding()]  # Add cmdlet features.
	$exp6=".\cscc --checkforcontentupdates --installupdates"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp6	
}


Function install-cscccontentall {
   	$exp8=".\cscc --installall"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp8
}


Function enable-csccallcontentrun {
   	$exp9=".\cscc --ear"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp9	
}


Function install-cscccontentall {
   	$exp10=".\cscc --installall"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp10	
}


Function start-csccscancomputersfromlist {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$file
	#path to computer list file

	)

   	$exp11=".\cscc.exe -f $file"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp11	
}


Function start-csccscancomputer {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$hostname
	#computerhostname

	)

   	$exp12=".\cscc.exe -h $hostname"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp12	
}

Function start-csccscancomputerwmifromlist {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$path
	#path to file

	)

   	$exp13=".\cscc.exe --wmi --file $path"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp13	

}

Function start-csccscancomputerwmifromdomain{
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$domain
	#domainname

	)

   	$exp14=".\cscc.exe --wmi --domain"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp14	
}

Function start-csccscancomputerwmifromou {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$ou
	#dn to ou

	)

   	$exp15=".\cscc.exe --wmi --ou $ou"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp15	
}

Function start-csccscandomain {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$domain
	#domainname

	)

   	$exp16=".\cscc.exe --scandomain $domain"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp16	
}

Function start-csccquietscan {
   
   	$exp7=".\cscc.exe -q"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $exp7
}
