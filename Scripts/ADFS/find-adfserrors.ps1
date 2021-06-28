#find-adfserrors
#Find ADFS Errors

$ADFSServers =  @("adfs01.example.com","adfs02.example.com")

$adfserrornumber = ADFS 2.0 error "6906F0A7-BDF5-4EDB-B624-DE9CDAE7938F"

$CorrelationActivityID = $adfserrornumber.Trim()

$fxpath = "*[System/Correlation[@ActivityID='{" + $CorrelationActivityID + "}']]"
$LogName = "AD FS 2.0/Admin"
$DebugLog = "AD FS 2.0 Tracing/Debug"
foreach ($ComputerName in $ADFSServers)
{
    try { 
        $ADFSevent = Get-WinEvent -ComputerName $ComputerName -LogName $LogName `
            -FilterXPath $fxpath  -ErrorAction Stop
        $ADFSevent | Format-list Id, MachineName, LogName, TimeCreated, Message
    }
    catch [Exception] {
        if ($_.Exception -match
            "No events were found that match the specified selection criteria") {
        }
        else
        {
            Throw $_
        }
    }
    try { 
        $ADFSevent = Get-WinEvent -ComputerName $ComputerName -Oldest -LogName $DebugLog `
            -FilterXPath $fxpath  -ErrorAction Stop
        $ADFSevent | Format-list Id, MachineName, LogName, TimeCreated, Message
    }
    catch [Exception] {
        if ($_.Exception -match
            "No events were found that match the specified selection criteria") {            
        }
        else
        {            
            Throw $_
        }
    }
}
 