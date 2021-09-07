#Get Empty GPOs
mkdir c:\temp\emptygpos
$emptygpocsv="c:\temp\emptygpos\emptygpos.csv"
$domain=read-host -prompt "Enter FQDN of Domain"
$EmptyGPO = New-Object System.Collections.ArrayList
$GPOs = Get-GPO -domain $domain -All  
Write-Verbose -Message "Found '$($GPOs.Count)'"
ForEach ($gpo  in $GPOs) { 
        [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
        if ($null -eq $GPOXMLReport.gpo.User.ExtensionData -and $null -eq $GPOXMLReport.gpo.Computer.ExtensionData) {
            $EmptyGPO += $gpo
        }
    }
    if (($EmptyGPO).Count -ne 0) {

    $EmptyGPO.DisplayName| export-csv -path $emptygpocsv -append -NoTypeInformation
    }
