############READ BELOW INSTRUCTIONS BEFORE UPDATING################################
#before running this script follow these steps to get the modules and versions in the proper json format
#go to powershell gallery find the az module and get the list of dependencies and the versions
#copy and past into a file named c:\temp\dependencies.txt without blank lines
#run the following to parse it to the json type format this script requires
########################RUN BELOW PARSING CODE#######################################
$a=get-content C:\temp\dependencies1.txt
$b=$a -replace ">" -replace ""
$c= $b.replace(" (", "(")
$d=$c.replace("= ", "=")
$e=$d.replace(')', '")')
$lines=$e.replace('(=', '" , "')
foreach ($line in $lines){$line.insert(0, '("')|out-file c:\temp\dependencies2.txt -append}

#####################END OF PARSER###################################################
#open file c:\temp\dependencies2.txt and replace below under "$azdependencies = @("


$ErrorActionPreference = "Stop"
connect-azaccount -usedeviceauthentication
$subscription = Get-AzSubscription
$SubscriptionId  = "$subscription.id"
$ResourceGroupName = "resource_group_name"
$AccountName = "automation_account_name"


$AzDependencies = @(
    ("Az.Accounts", "1.9.3"),
    ("Az.Advisor", "1.1.1"),
    ("Az.Aks" , "1.2.0"),
    ("Az.AnalysisServices" , "1.1.4"),
    ("Az.ApiManagement" , "2.1.0"),
    ("Az.ApplicationInsights" , "1.1.0"),
    ("Az.Automation" , "1.4.0"),
    ("Az.Batch" , "3.1.0"),
    ("Az.Billing" , "1.0.3"),
    ("Az.Cdn" , "1.4.3"),
    ("Az.CognitiveServices" , "1.5.1"),
    ("Az.Compute" , "4.3.0"),
    ("Az.ContainerInstance" , "1.0.3"),
    ("Az.ContainerRegistry" , "1.1.1"),
    ("Az.DataBoxEdge" , "1.1.0"),
    ("Az.DataFactory" , "1.10.0"),
    ("Az.DataLakeAnalytics" , "1.0.2"),
    ("Az.DataLakeStore" , "1.2.8"),
    ("Az.DataShare" , "1.0.0"),
    ("Az.DesktopVirtualization" , "1.0.0"),
    ("Az.DeploymentManager" , "1.1.0"),
    ("Az.DevTestLabs" , "1.0.2"),
    ("Az.Dns" , "1.1.2"),
    ("Az.EventGrid" , "1.3.0"),
    ("Az.EventHub" , "1.5.0"),
    ("Az.FrontDoor" , "1.6.1"),
    ("Az.Functions" , "1.0.1"),
    ("Az.HDInsight" , "3.5.0"),
    ("Az.HealthcareApis" , "1.1.0"),
    ("Az.IotHub" , "2.5.0"),
    ("Az.KeyVault" , "2.1.0"),
    ("Az.LogicApp" , "1.3.2"),
    ("Az.MachineLearning" , "1.1.3"),
    ("Az.Maintenance" , "1.1.0"),
    ("Az.ManagedServices" , "1.1.0"),
    ("Az.MarketplaceOrdering" , "1.0.2"),
    ("Az.Media" , "1.1.1"),
    ("Az.Monitor" , "2.1.0"),
    ("Az.Network" , "3.3.0"),
    ("Az.NotificationHubs" , "1.1.1"),
    ("Az.OperationalInsights" , "2.3.0"),
    ("Az.PolicyInsights" , "1.3.1"),
    ("Az.PowerBIEmbedded" , "1.1.2"),
    ("Az.PrivateDns" , "1.0.3"),
    ("Az.RecoveryServices" , "2.11.1"),
    ("Az.RedisCache" , "1.2.1"),
    ("Az.Relay" , "1.0.3"),
    ("Az.Resources" , "2.5.0"),
    ("Az.ServiceBus" , "1.4.1"),
    ("Az.ServiceFabric" , "2.1.0"),
    ("Az.SignalR" , "1.2.0"),
    ("Az.Sql" , "2.9.1"),
    ("Az.SqlVirtualMachine" , "1.1.0"),
    ("Az.Storage" , "2.4.0"),
    ("Az.StorageSync" , "1.3.0"),
    ("Az.StreamAnalytics" , "1.0.1"),
    ("Az.Support" , "1.0.0"),
    ("Az.TrafficManager" , "1.0.4"),
    ("Az.Websites" , "1.11.0")
    #("Az", "4.5.0")  AZ Base module can not be uploaded to azure automation
)

Set-AzContext -SubscriptionId $SubscriptionId

foreach ($module in $AzDependencies.GetEnumerator()) {

    $moduleName = $module[0]

    $moduleVersion = $module[1]

    Write-Output "$($moduleName): $($moduleVersion)"
 
    $result = Get-AzAutomationModule -AutomationAccountName $AccountName -ResourceGroupName $resourcegroupname -Name $moduleName

    if (($result -eq $null) -or (($result -ne $null) -and (($result.Version -ne $moduleVersion) -or ($result.ProvisioningState -ne "Succeeded")))){

        New-AzAutomationModule -AutomationAccountName $AccountName -ResourceGroupName $resourcegroupname -Name $moduleName -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"

 $updatedResult = Get-AzAutomationModule -AutomationAccountName $AccountName -ResourceGroupName $resourcegroupname -Name $moduleName
}
}

