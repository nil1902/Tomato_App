@echo off
echo ========================================
echo Rebuilding Windows App with Network Fix
echo ========================================
echo.

echo Step 1: Cleaning build...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Deleting old build folder...
rmdir /s /q build 2>nul

echo.
echo Step 4: Building for Windows...
flutter build windows --release

echo.
echo Step 5: Running app...
flutter run -d windows

pause
