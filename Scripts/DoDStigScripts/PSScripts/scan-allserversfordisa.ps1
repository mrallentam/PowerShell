#auto DISA scan list of computers for disa and report
$list="c:\temp\serverlist.txt"

#update Scap Program
function update-csccfiles {
$expression=".\cscc.exe --update"

	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
    invoke-expression -command $expression

}

#Update all stigs
Function install-cscccontentupdates {
   
 [CmdletBinding()]  # Add cmdlet features.
	$expression2=".\cscc --checkforcontentupdates --installupdates"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $expression2	
}

#enable all stigs
Function enable-csccall {
   
	$expression3=".\cscc.exe -ea"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	invoke-expression -command $expression3
}


Function start-csccscancomputersfromlist {
   
 [CmdletBinding()]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory=$True)]
        [string]$file
	#path to computer list file

	)

   	$expression4=".\cscc.exe -f $file"
	set-location -path "C:\Program Files\SCAP Compliance Checker 5.4.1"
	Invoke-expression -command $expression4	
}

####################################################################
update-csccfiles

#GET and install all uppdate all stigs
install-cscccontentupdates

#Enable all stigs
enable-csccall

#STart scanning and reporting
start-csccscancomputersfromlist -file $list

