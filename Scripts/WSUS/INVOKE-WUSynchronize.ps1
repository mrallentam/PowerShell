
#Get Update Server
$wsus=[Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()

#Get Configuration
$wsus.GetConfiguration()

#Get Subscription
$wsus.GetSubscription()

#Synchronize!
$wsus.GetSubscription().StartSynchronization()

#Check progress
#$wsus.GetSubscription().GetSynchronizationProgress()

#Get Last Sync
#$wsus.GetSubscription().GetLastSynchronizationInfo()

