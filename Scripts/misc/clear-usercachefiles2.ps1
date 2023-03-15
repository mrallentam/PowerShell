##clear environment cache
####################################################################                                             #

$localuser=$env:username
# -  Remove-CacheFiles
Function Remove-CacheFiles {
    param([Parameter(Mandatory=$true)][string]$path)    
    BEGIN 
    {
        $originalVerbosePreference = $VerbosePreference
        $VerbosePreference = 'Continue'  
    }
    PROCESS 
    {
        if((Test-Path $path))
        {
            if([System.IO.Directory]::Exists($path))
            {
                try 
                {
                    if($path[-1] -eq '\')
                    {
                        [int]$pathSubString = $path.ToCharArray().Count - 1
                        $sanitizedPath = $path.SubString(0, $pathSubString)
                        Remove-Item -Path "$sanitizedPath\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                    }
                    else 
                    {
                        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose              
                    } 
                } catch { }
            }
            else 
            {
                try 
                {
                    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue -Verbose
                } catch { }
            }
        }    
    }
    END 
    {
        $VerbosePreference = $originalVerbosePreference
    }
}


#- Clear-GlobalWindowsCache                                        #
Function Clear-GlobalWindowsCache {
    Remove-CacheFiles 'C:\Windows\Temp' 
    Remove-CacheFiles "C:\`$Recycle.Bin"
    Remove-CacheFiles "C:\Windows\Prefetch"
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 255
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351
}



#- Clear-WindowsUserCacheFiles                                     #
Function Clear-WindowsUserCacheFiles {
    param([string]$user=$env:USERNAME)
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Temp"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\WER"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\INetCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\INetCookies"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IECompatCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IECompatUaCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IEDownloadHistory"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files"    
}


#- Stop-BrowserSessions                                            #
Function Stop-BrowserSessions {
   $activeBrowsers = Get-Process Firefox*,Chrome*,Waterfox*,Edge*
   ForEach($browserProcess in $activeBrowsers)
   {
       try 
       {
           $browserProcess.CloseMainWindow() | Out-Null 
       } catch { }
   }
}



#- Clear-ChromeCache                                               #
Function Clear-ChromeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Google\Chrome\User Data\Default"))
    {
        $chromeAppData = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default" 
        $possibleCachePaths = @('Cache','Cache2\entries\','Cookies','History','Top Sites','VisitedLinks','Web Data','Media Cache','Cookies-Journal','ChromeDWriteFontCache')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$chromeAppData\$cachePath"
        }      
    } 
}

#- Clear-EdgeCache   
Function Clear-EdgeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"))
    {
        $EdgeAppData = "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"
        $possibleCachePaths = @('Cache','Cache2\entries','Cookies','History','Top Sites','Visited Links','Web Data','Media History','Cookies-Journal')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$EdgeAppData$cachePath"
        }
        }
}



#- Clear-TeamsCacheFiles                                           #
Function Clear-TeamsCacheFiles { 
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Roaming\Microsoft\Teams"))
    {
        $possibleCachePaths = @('cache','blob_storage','databases','gpucache','Indexeddb','Local Storage','application cache\cache')
        $teamsAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Roaming\Microsoft\Teams" | Where-Object { $_.Name -match 'Default' }[0]).FullName
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$teamsAppDataPath\$cachePath"
        }
    }   
}

#- Clear-UserCacheFiles                                            #
Function Clear-UserCacheFiles {
    # Stop-BrowserSessions
    ForEach($localUser in (Get-ChildItem 'C:\users').Name)
    {
        Clear-ChromeCache $localUser
        Clear-EdgeCacheFiles $localUser
        Clear-WindowsUserCacheFiles $localUser
        Clear-TeamsCacheFiles $localUser
    }
}
