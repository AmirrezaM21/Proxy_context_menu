@echo off
color 0A

:: ============================================
:: USER CONFIGURABLE VARIABLES
:: Edit these paths to match your system
:: ============================================

:: Proxy server configuration
set "PROXY_ADDRESS=127.0.0.1"
set "PROXY_PORT=8085"

:: ============================================
:: END OF USER CONFIGURABLE VARIABLES
:: ============================================

:: Build full proxy string from variables
set "PROXY_FULL=%PROXY_ADDRESS%:%PROXY_PORT%"

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    echo Right-click the file and select "Run as administrator"
    timeout /t 3 >nul
    exit /b 1
)

:: Proxy is disabled, enable it
echo [1/4] Enabling proxy %PROXY_FULL%...
            
:: Clear any existing proxy settings first
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /f > nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f > nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f > nul 2>&1
            
:: Set new proxy configuration
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%PROXY_FULL%" /t REG_SZ /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /d "<local>" /t REG_SZ /f > nul
            
echo [4/4] Proxy enabled successfully!
exit /b 0