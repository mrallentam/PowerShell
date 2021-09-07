#Get unlinked GPOs
mkdir c:\temp\unlinkedgpos
$csvfilepath="c:\temp\unlinkedgpos\unlinkedgpos.csv"
$domain=read-host -prompt "Enter FQDN of Domain"
$UnlinkedGPO = New-Object System.Collections.ArrayList
 $AllGPOs = Get-GPO -domain $domain -All  
    ForEach ($1gpo  in $AllGPOs) { 
        Write-Verbose -Message "Checking '$($1gpo.DisplayName)' link"
        [xml]$GPOXMLReport = $1gpo | Get-GPOReport -ReportType xml
        if ($null -eq $GPOXMLReport.GPO.LinksTo) { 
            $UnlinkedGPO += $1gpo
        }
    }
    if (($UnlinkedGPO).Count -ne 0) {
    $UnlinkedGPO.DisplayName| export-csv -path $csvfilepath -append -NoTypeInformation
    }
