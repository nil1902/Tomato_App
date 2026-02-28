@echo off
echo Cleaning Flutter build cache...
flutter clean
echo.
echo Deleting build folder...
rmdir /s /q build 2>nul
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Build cleaned successfully!
echo Now run: flutter run -d windows
pause
