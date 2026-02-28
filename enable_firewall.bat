@echo off
echo Enabling Windows Firewall rules for zomato_app...
echo.
echo This script must be run as Administrator!
echo.

REM Enable all firewall rules for zomato_app
powershell -Command "Get-NetFirewallRule -DisplayName 'zomato_app' | Set-NetFirewallRule -Enabled True"

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Firewall rules enabled!
    echo.
    powershell -Command "Get-NetFirewallRule -DisplayName 'zomato_app' | Select-Object DisplayName, Enabled, Direction, Action"
) else (
    echo.
    echo ERROR: Failed to enable firewall rules.
    echo Please run this script as Administrator.
)

echo.
pause
