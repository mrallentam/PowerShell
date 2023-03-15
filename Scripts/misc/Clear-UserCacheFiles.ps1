#------------------------------------------------------------------#
#- Clear-UserCacheFiles                                            #
#------------------------------------------------------------------#
Function Clear-UserCacheFiles {
    # Stop-BrowserSessions
    ForEach($localUser in (Get-ChildItem 'C:\users').Name)
    {
        Clear-ChromeCache $localUser
        Clear-EdgeCacheFiles $localUser
        Clear-FirefoxCacheFiles $localUser
        Clear-WindowsUserCacheFiles $localUser
        Clear-TeamsCacheFiles $localUser
    }
}
