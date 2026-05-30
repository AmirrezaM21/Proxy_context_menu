@echo off
:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run as Administrator!
    pause
    exit /b 1
)

echo Removing Proxy Settings context menu...

:: Remove registry entries
reg delete "HKCR\Directory\Background\shell\ProxySettings" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOff" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOn" /f >nul 2>&1

:: Restart explorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo Uninstall complete! Context menu removed.
timeout /t 2 >nul