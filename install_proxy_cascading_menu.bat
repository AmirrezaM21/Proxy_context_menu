@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    pause
    exit /b 1
)

:: Paths
set "SCRIPT_DIR=D:\Scripts\Proxy_context_menu"
set "ICON_PATH=D:\Scripts\Proxy_context_menu\proxy.ico"

:: Create directories if they don't exist
if not exist "%SCRIPT_DIR%" mkdir "%SCRIPT_DIR%"

:: Create proxy_on.bat
if not exist "%SCRIPT_DIR%\proxy_on.bat" (
    echo Creating proxy_on.bat...
    (
        echo @echo off
        echo color 0A
        echo echo Enabling proxy: 127.0.0.1:8085...
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f ^>nul
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "127.0.0.1:8085" /t REG_SZ /f ^>nul
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /d "^<local^>" /t REG_SZ /f ^>nul
        echo echo Proxy enabled successfully!
        echo timeout /t 2 ^>nul
    ) > "%SCRIPT_DIR%\proxy_on.bat"
)

:: Create proxy_off.bat
if not exist "%SCRIPT_DIR%\proxy_off.bat" (
    echo Creating proxy_off.bat...
    (
        echo @echo off
        echo color 0C
        echo echo Disabling proxy...
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f ^>nul
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "" /f ^>nul
        echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f ^>nul
        echo netsh winhttp reset proxy ^>nul
        echo echo Proxy disabled successfully!
        echo timeout /t 2 ^>nul
    ) > "%SCRIPT_DIR%\proxy_off.bat"
)

:: Remove existing entries
reg delete "HKCR\Directory\Background\shell\ProxySettings" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOff" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOn" /f >nul 2>&1

:: Create context menu with SubCommands for cascading menu
reg add "HKCR\Directory\Background\shell\ProxySettings" /v "MUIVerb" /t REG_SZ /d "Proxy Settings" /f
reg add "HKCR\Directory\Background\shell\ProxySettings" /v "ProgrammaticAccessOnly" /t REG_SZ /d "" /f
reg add "HKCR\Directory\Background\shell\ProxySettings" /v "Icon" /t REG_SZ /d "%ICON_PATH%" /f
reg add "HKCR\Directory\Background\shell\ProxySettings" /v "Position" /t REG_SZ /d "Top" /f
reg add "HKCR\Directory\Background\shell\ProxySettings" /v "SubCommands" /t REG_SZ /d "ProxyOff;ProxyOn" /f

:: Create Off command in CommandStore (runs as admin)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOff" /ve /t REG_SZ /d "Off" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOff" /v "Icon" /t REG_SZ /d "%ICON_PATH%" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOff\command" /ve /t REG_SZ /d "powershell.exe -Command \"Start-Process cmd -ArgumentList '/c \"\"%SCRIPT_DIR%\\proxy_off.bat\"\"' -Verb RunAs -WindowStyle Hidden\"" /f

:: Create On command in CommandStore (runs as admin)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOn" /ve /t REG_SZ /d "127.0.0.1:8085" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOn" /v "Icon" /t REG_SZ /d "%ICON_PATH%" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ProxyOn\command" /ve /t REG_SZ /d "powershell.exe -Command \"Start-Process cmd -ArgumentList '/c \"\"%SCRIPT_DIR%\\proxy_on.bat\"\"' -Verb RunAs -WindowStyle Hidden\"" /f

echo.
echo ============================================
echo SUCCESS! Cascading context menu installed!
echo ============================================
echo.
pause