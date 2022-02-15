@echo off
set version=1.1.11.2
set branch=master
set pwsh=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command
title DBD Private Server (%version%)
echo  ___  ___ ___    ___     _          _         ___
echo ^|   \^| _ )   \  ^| _ \_ _(_)_ ____ _^| ^|_ ___  / __^| ___ _ ___ _____ _ _
echo ^| ^|) ^| _ \ ^|) ^| ^|  _/ '_^| \ V / _` ^|  _/ -_) \__ \/ -_) '_\ V / -_) '_^|
echo ^|___/^|___/___/  ^|_^| ^|_^| ^|_^|\_/\__,_^|\__\___^| ^|___/\___^|_^|  \_/\___^|_^|
echo.
echo DBD Private Server (%version%)
echo.
%pwsh% "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webRequest = Invoke-WebRequest https://raw.githubusercontent.com/ModByDaylight/PrivateServer/%branch%/info.txt -UseBasicParsing; $paths = ConvertFrom-StringData -StringData $webRequest.Content; if ( $paths['latestVersion'] -gt '%version%' ) { 'Update available. Please download the latest version. ' + '(' + $paths['latestVersion'] + ')'; echo 'https://github.com/ModByDaylight/PrivateServer/releases/latest' '' } }"
if exist gamepath.txt (
    set /p path=<gamepath.txt
) else goto :paths
call :platformCheck
:start
echo [1]. Launch Live
echo [2]. Launch Private Server
echo [3]. Setup Private Server
echo [4]. Install Mods
echo.
set launchOption=
set /p launchOption="Select an option: "
if not '%launchOption%'=='' set launchOption=%launchOption:~0,1%
if '%launchOption%'=='1' goto :launchLive
if '%launchOption%'=='2' goto :launchPrivate
if '%launchOption%'=='3' goto :setupPrivate
if '%launchOption%'=='4' goto :installMods
echo "%launchOption%" is not valid, try again.
echo.
goto :start
:paths
set path=C:\Program Files (x86)\Steam\steamapps\common\Dead by Daylight
echo Is this where DBD is installed? %path% [Y/N]
set /p installPath=
if /i '%installPath%'=='Y' goto :setupPrivate
if /i '%installPath%'=='YES' goto :setupPrivate
if /i '%installPath%'=='N' goto :dbdlocation
if /i '%installPath%'=='NO' goto :dbdlocation
echo "%installPath%" is not valid, try again.
goto :paths
:dbdlocation
echo Please set your directory below.
set /p path=
goto :setupPrivate
:launchLive
echo Copying Live Executables...
if exist "%path%\DeadByDaylight.exe" del "%path%\DeadByDaylight.exe"
if exist "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe" del "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe"
copy LiveExecutables\DeadByDaylight.exe "%path%" 
copy LiveExecutables\DeadByDaylight-%executables%-Shipping.exe "%path%\DeadByDaylight\Binaries\%executables%"
echo Launching Dead by Daylight
start %launch%
goto :end
:launchPrivate
echo Copying Private Server Executables...
if exist "%path%\DeadByDaylight.exe" del "%path%\DeadByDaylight.exe"
if exist "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe" del "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe"
copy PrivateExecutables\DeadByDaylight.exe "%path%" 
copy PrivateExecutables\DeadByDaylight-%executables%-Shipping.exe "%path%\DeadByDaylight\Binaries\%executables%"
echo Checking mod compatibility...
%pwsh% "& {Get-ChildItem -Path '%path%\DeadByDaylight\Content\Paks\~mods\*' -Include *.pak, *.sig -Recurse | Rename-Item -NewName {$_.name -replace 'WindowsNoEditor','%platform%'} }"
echo Launching Private Server
start %launch%
goto :end
:setupPrivate
if not exist "%path%\EasyAntiCheat\EasyAntiCheat_Setup.exe" (
    echo Invalid directory, try again.
    goto :dbdlocation
)
echo %path%>gamepath.txt
call :platformCheck
echo Importing mods...
if not exist "%path%\DeadByDaylight\Content\Paks\~mods" md "%path%\DeadByDaylight\Content\Paks\~mods"
%pwsh% "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webRequest = Invoke-WebRequest https://raw.githubusercontent.com/ModByDaylight/PrivateServer/%branch%/DefaultMods.json -UseBasicParsing; $Data = ConvertFrom-Json $webRequest.Content; $Data.DefaultMods.File | ForEach-Object { 'Downloading' + ' ' + $_.Name + ' ' + '(' + $_.Version + ')' + ' ' + 'by' + ' ' + $_.Author; Invoke-WebRequest -Uri $_.Path -OutFile 'Mods.zip'; Expand-Archive -Path 'Mods.zip' -DestinationPath 'temp' -Force; Remove-Item -Path 'Mods.zip' -Force } }"
%pwsh% "& {Get-ChildItem -Path 'temp\*' -Include *.pak, *.sig -Recurse | Rename-Item -NewName {$_.name -replace 'WindowsNoEditor','%platform%'}; Get-ChildItem -Path 'temp\*' -Include *.pak, *.sig -Recurse | Move-Item -Destination '%path%\DeadByDaylight\Content\Paks\~mods' -Force; Remove-Item -Path 'temp' -Force -Recurse }"
if exist "%path%\DeadByDaylight.exe" del "%path%\DeadByDaylight.exe"
if exist "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe" del "%path%\DeadByDaylight\Binaries\%executables%\DeadByDaylight-%executables%-Shipping.exe"
%pwsh% "& {'Downloading Private Server Executables...'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webRequest = Invoke-WebRequest https://raw.githubusercontent.com/ModByDaylight/PrivateServer/%branch%/info.txt -UseBasicParsing; $paths = ConvertFrom-StringData -StringData $webRequest.Content; Invoke-WebRequest -Uri $paths['executablesPrivate%executables%'] -OutFile 'PrivateExecutables.zip'; Expand-Archive -Path 'PrivateExecutables.zip' -DestinationPath 'PrivateExecutables' -Force; Remove-Item -Path 'PrivateExecutables.zip' -Force }"
%pwsh% "& {'Downloading Live Executables...'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webRequest = Invoke-WebRequest https://raw.githubusercontent.com/ModByDaylight/PrivateServer/%branch%/info.txt -UseBasicParsing; $paths = ConvertFrom-StringData -StringData $webRequest.Content; Invoke-WebRequest -Uri $paths['executablesLive%executables%'] -OutFile 'LiveExecutables.zip'; Expand-Archive -Path 'LiveExecutables.zip' -DestinationPath 'LiveExecutables' -Force; Remove-Item -Path 'LiveExecutables.zip' -Force }"
echo Installing Private Server Executables...
copy PrivateExecutables\DeadByDaylight.exe "%path%"
copy PrivateExecutables\DeadByDaylight-%executables%-Shipping.exe "%path%\DeadByDaylight\Binaries\%executables%"
echo Setup Complete!
goto :end
:installMods
%pwsh% "& {''; 'Installed Mods:'; ''; Get-ChildItem '%path%\DeadByDaylight\Content\Paks\~mods\*.pak' -Name -Recurse }"
%pwsh% "& {$webRequest = Invoke-WebRequest https://raw.githubusercontent.com/ModByDaylight/PrivateServer/%branch%/DownloadMods.json -UseBasicParsing; $Data = ConvertFrom-Json $webRequest.Content; $number=0; ''; 'Available Mods:'; ''; $Data.DownloadMods.File | ForEach-Object { $number=$number+1; '[' + $number + ']. ' + $_.Name + ' ' + '(' + $_.Version + ')' + ' ' + 'by' + ' ' + $_.Author }; ''; $ErrorActionPreference = 'SilentlyContinue'; $input=Read-Host 'Select an option'; $Data.DownloadMods.File[$input-1] | ForEach-Object { ''; 'Downloading' + ' ' + $_.Name + ' ' + '(' + $_.Version + ')' + ' ' + 'by' + ' ' + $_.Author; ''; Invoke-WebRequest -Uri $_.Path -OutFile 'Mods.zip'; Expand-Archive -Path 'Mods.zip' -DestinationPath 'temp' -Force; Remove-Item -Path 'Mods.zip' -Force } }"
%pwsh% "& {Get-ChildItem -Path 'temp\*' -Include *.pak, *.sig -Recurse | Rename-Item -NewName {$_.name -replace 'WindowsNoEditor','%platform%'}; Get-ChildItem -Path 'temp\*' -Include *.pak, *.sig -Recurse | Move-Item -Destination '%path%\DeadByDaylight\Content\Paks\~mods' -Force; Remove-Item -Path 'temp' -Force -Recurse }"
goto :end
:platformCheck
if exist "%path%\DeadByDaylight\Content\Paks\pakchunk0-WindowsNoEditor.pak" (
    set platform=WindowsNoEditor
    set executables=Win64
    set launch=steam://rungameid/381210
)
if exist "%path%\DeadByDaylight\Content\Paks\pakchunk0-EGS.pak" (
    set platform=EGS
    set executables=EGS
    set launch=com.epicgames.launcher://apps/Brill?action=launch&silent=true
)
if exist "%path%\DeadByDaylight\Content\Paks\pakchunk0-WinGDK.pak" (
    set platform=WinGDK
    set executables=WinGDK
    set launch=shell:appsFolder\BehaviourInteractive.DeadbyDaylightWindows_b1gz2xhdanwfm!AppDeadByDaylightShipping
    echo The Private Server is currently unsupported on the Microsoft Store version of Dead by Daylight.
    goto :end
)
goto :eof
:end
pause