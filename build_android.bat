@echo off
echo ========================================
echo Building Android APK for CMF Phone 1
echo Target: Android 16 (API 35)
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building APK (Release)...
flutter build apk --release

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo Install on your CMF Phone 1:
echo 1. Copy APK to your phone
echo 2. Enable "Install from Unknown Sources"
echo 3. Tap the APK to install
echo.
pause
