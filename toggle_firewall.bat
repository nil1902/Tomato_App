@echo off
echo ========================================
echo Windows Firewall Toggle Script
echo ========================================
echo.
echo 1. Disable Firewall (Testing)
echo 2. Enable Firewall (Restore)
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo Disabling Windows Firewall...
    netsh advfirewall set allprofiles state off
    echo.
    echo ✓ Firewall DISABLED
    echo ⚠️ Remember to enable it after testing!
    echo.
) else if "%choice%"=="2" (
    echo.
    echo Enabling Windows Firewall...
    netsh advfirewall set allprofiles state on
    echo.
    echo ✓ Firewall ENABLED
    echo.
) else (
    echo Invalid choice!
)

pause
