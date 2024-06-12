#############################################################
##
## Base System Installation Script for Windows11 
##
## Created 2024 by Dennis Gunia (www.dennisgunia.de)
## Version 1
##
#############################################################

Function baseAppxRemoveBloat {
    Write-Output "Removing Bloat Appx Packages"
    $bloatWare=
        "Microsoft.GamingApp",
        "Microsoft.BingWeather",
        "Microsoft.BingNews",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxGameOverlay",
        "Microsoft.Xbox.TCUI"
    

    $bloatWare | %{
        Write-Output "Remove: $_"
        $pkg = Get-AppxPackage $_ 
        if ($pkg) {
            Remove-AppxPackage $pkg
        } else {
            Write-Output "$_ already removed"
        }
        
    }
}

Function baseProtectPrivacy {
            
    #Disables Windows Feedback Experience
    Write-Output "Disabling Windows Feedback Experience program"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (Test-Path $Advertising) {
        Set-ItemProperty $Advertising Enabled -Value 0 
    }
            
    #Stops Cortana from being used as part of your Windows Search Function
    Write-Output "Stopping Cortana from being used as part of your Windows Search Function"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }

    #Disables Web Search in Start Menu
    Write-Output "Disabling Bing Search in Start Menu"
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
            
    #Stops the Windows Feedback Experience from sending anonymous data
    Write-Output "Stopping the Windows Feedback Experience program"
    $Period = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

    #Prevents bloatware applications from returning and removes Start Menu suggestions               
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0          
    
    #Prepping mixed Reality Portal for removal    
    Write-Output "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
    }

    #Disables Wi-fi Sense
    Write-Output "Disabling Wi-Fi Sense"
    $WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
    $WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
    $WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    If (!(Test-Path $WifiSense1)) {
        New-Item $WifiSense1
    }
    Set-ItemProperty $WifiSense1  Value -Value 0 
    If (!(Test-Path $WifiSense2)) {
        New-Item $WifiSense2
    }
    Set-ItemProperty $WifiSense2  Value -Value 0 
    Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 
        
    #Disables live tiles
    Write-Output "Disabling live tiles"
    $Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
    If (!(Test-Path $Live)) {      
        New-Item $Live
    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 
        
    #Turns off Data Collection via the Allow Telemetry key by changing it to 0
    Write-Output "Turning off Data Collection"
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
    If (Test-Path $DataCollection1) {
        Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection2) {
        Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection3) {
        Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
    }
    
    #Disabling Location Tracking
    Write-Output "Disabling Location Tracking"
    $SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
    $LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
    If (!(Test-Path $SensorState)) {
        New-Item $SensorState
    }
    Set-ItemProperty $SensorState SensorPermissionState -Value 0 
    If (!(Test-Path $LocationConfig)) {
        New-Item $LocationConfig
    }
    Set-ItemProperty $LocationConfig Status -Value 0 
        
    #Disables People icon on Taskbar
    Write-Output "Disabling People icon on Taskbar"
    $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
    If (Test-Path $People) {
        Set-ItemProperty $People -Name PeopleBand -Value 0
    }
        
    #Disables scheduled tasks that are considered unnecessary 
    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask
    Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
    Get-ScheduledTask  DmClient | Disable-ScheduledTask
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask

    Write-Output "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled

    
    Write-Output "Removing CloudStore from registry if it exists"
    $CloudStore = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore'
    If (Test-Path $CloudStore) {
        Stop-Process Explorer.exe -Force
        Remove-Item $CloudStore -Recurse -Force
        Start-Process Explorer.exe -Wait
    }
    Clear-Host
}

Function baseDisableCortana {
    Write-Host "Disabling Cortana" -ForegroundColor Red 
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0
    Write-Host "Done" -ForegroundColor Red -BackgroundColor White `n
}

Function baseRemove3dObjects {
    #Removes 3D Objects from the 'My Computer' submenu in explorer
    Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (Test-Path $Objects32) {
        Remove-Item $Objects32 -Recurse
        Stop-Process -ProcessName explorer -Force
    }
    If (Test-Path $Objects64) {
        Remove-Item $Objects64 -Recurse 
        Stop-Process -ProcessName explorer -Force
    }
    if ( 
	    ( -not (Test-Path $Objects32) ) -and (-not (Test-Path $Objects64)) 
        ) 
        {
            Write-Host "Done"-ForegroundColor Green -BackgroundColor white `n 
        }
    Start-Process explorer -Wait
}

function baseLeftMenu {
    $ErrorActionPreference = 'silentlycontinue'

    $explorerPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    Write-Host "Setting Start Menu to Left" -ForegroundColor Red
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $explorerPath -Name TaskbarAl -Value 0
    }
    $checkStart = Get-ItemProperty -Path $explorerPath -Name TaskbarAl
    if( $checkStart.TaskbarAl -eq 0 ) {
        Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
    }
}

function baseRemoveTaskIcon {
    $ErrorActionPreference = 'silentlycontinue'

    $explorerPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    Write-Host "Setting Start Menu to Left" -ForegroundColor Red
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $explorerPath -Name TaskbarMn -Value 0
    }
    $checkChat = Get-ItemProperty -Path $explorerPath -Name TaskbarMn
    if( $checkChat.TaskbarMn -eq 0 ) {
        Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
    }

    Write-Host "Removing Taskview Button" -ForegroundColor Red
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $explorerPath -Name ShowTaskViewButton -Value 0
    }
    $checkChat = Get-ItemProperty -Path $explorerPath -Name ShowTaskViewButton
    if( $checkChat.ShowTaskViewButton -eq 0 ) {
        Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
    }

    Write-Host "Removing Widget Button" -ForegroundColor Red
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $explorerPath -Name TaskbarDa -Value 0
    }
    $checkChat = Get-ItemProperty -Path $explorerPath -Name TaskbarDa
    if( $checkChat.TaskbarDa -eq 0 ) {
        Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
    }


    Write-Host "Removing search on Taskbar" -ForegroundColor Red
    $SearchKeyPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Search"
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $SearchKeyPath -Name SearchboxTaskbarMode -Value 0
    }
    $checkSearch = Get-ItemProperty -Path $SearchKeyPath -Name SearchboxTaskbarMode
    if( $checkSearch.SearchboxTaskbarMode -eq 0 ) {
        Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
    }

    # Remove edge taskbar icon
    Write-Host "Removing Microsft Edge from taskbar" -ForegroundColor Red
    $edgeKeyPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
    if(Test-Path $edgeKeyPath) {
        Remove-Item $edgeKeyPath -Recurse -Force
    }
    Stop-Process -Processname Explorer -WarningAction SilentlyContinue -Force
    Start-Sleep 5
    Start-Process Explorer -Wait -WarningAction SilentlyContinue
    Start-Sleep 1
    Write-Host "Done" -ForegroundColor Green -BackgroundColor white `n
}

Function baseRemoveKeys {
        
    #These are the registry keys that it will delete.
            
    $Keys = @(
            
        #Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            
        #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
        #Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
               
        #Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
        
    #This writes the output of each key it is removing and also removes the keys listed above.
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse
    }
    Clear-Host
}

Function disableMicrosoftAccountLogin {
   ## TODO 
}

Function installAppsMsi {
    class MSIApp {
        [string]$url
        [string]$msiname;
    }

    $apps = @(
        [MSIApp]@{msiname='firefox';url='https://download-installer.cdn.mozilla.net/pub/firefox/releases/127.0/win64/de/Firefox%20Setup%20127.0.msi'}
        [MSIApp]@{msiname='thunderbird';url='https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/115.11.1/win64/de/Thunderbird%20Setup%20115.11.1.msi'}
        [MSIApp]@{msiname='vlc';url='https://mirror.netcologne.de/videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.msi'}
        [MSIApp]@{msiname='7zip';url='https://objects.githubusercontent.com/github-production-release-asset-2e65be/466446150/8a2f3a8d-ea23-42f9-b9eb-4ac6be71f806?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20240612%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240612T184518Z&X-Amz-Expires=300&X-Amz-Signature=76ce7e535a78b7518d5cc2df55dab4dc6cda797df46fc682831c2af6e90a1a26&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=466446150&response-content-disposition=attachment%3B%20filename%3D7z2406-x64.msi&response-content-type=application%2Foctet-stream'}
    )
    New-Item -Path c:\temp -ItemType "directory" -Force | Out-Null
    $apps | %{
        $msi = "c:\temp\$($_.msiname).msi"
        $url = $_.url
        Write-Host "Download $msi from $url"
        Invoke-WebRequest $url -OutFile $msi
        Write-Host "Install $msi ..."
        $installproc = Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/I c:\temp\thunderbird.msi /quiet " -PassThru -Wait
        $exitCode = $installproc.ExitCode
        
        if ( $exitCode -eq 0 ){
            Write-Host "Process exited with $exitCode" -ForegroundColor Green
        }else{
            Write-Host "Process failed with exit code $exitCode" -ForegroundColor Red
        }
    }

}


Function installAppsExe {
    class EXEApp {
        [string]$url;
        [string]$msiname;
        [string]$params;
    }

    $apps = @(
        [EXEApp]@{msiname='keepass';params='/VERYSILENT';url='https://altushost-swe.dl.sourceforge.net/project/keepass/KeePass%202.x/2.57/KeePass-2.57-Setup.exe?viasf=1'}
        [EXEApp]@{msiname='npp';params='/S /D=C:\NotepadPlusPlus';url='https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.8/npp.8.6.8.Installer.exe'}

    )
    New-Item -Path c:\temp -ItemType "directory" -Force | Out-Null
    $apps | %{
        $exe = "c:\temp\$($_.msiname).exe"
        $url = $_.url
        Write-Host "Download $exe from $url"
        Invoke-WebRequest $url -OutFile $exe
        Write-Host "Install $exe ..."
        $installproc = Start-Process $exe -ArgumentList $_.params -PassThru -Wait
        $exitCode = $installproc.ExitCode
        
        if ( $exitCode -eq 0 ){
            Write-Host "Process exited with $exitCode" -ForegroundColor Green
        }else{
            Write-Host "Process failed with exit code $exitCode" -ForegroundColor Red
        }
    }

}



Function showFileExt {
    Write-Host "Set Registry: Show file extensions"
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
   
}

Function setDefaultBrowser {
    Write-Host "Set Registry: Set Firefox as default browser"
    'http', 'https' | ForEach-Object {
        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$_\UserChoice"
        Set-ItemProperty $regPath ProgId "FirefoxURL-308046B0AF4A39CB"
    }
     Write-Host "Set Registry: Set Thunderbird as mail client"
    'mailto' | ForEach-Object {
        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$_\UserChoice"
        Set-ItemProperty $regPath ProgId "Thunderbird.Url.mailto"
    }
}

Function mountNetworkDrives {
    #TODO
}

#baseAppxRemoveBloat
#baseRemoveKeys
#baseProtectPrivacy
#baseDisableCortana
#baseRemove3dObjects
#baseLeftMenu
#baseRemoveTaskIcon

#installApps
#installAppsExe
showFileExt
setDefaultBrowser