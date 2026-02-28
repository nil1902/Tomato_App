@echo off
echo Rebuilding Windows app with JSON fix...
echo.
flutter pub get
echo.
echo Starting app...
flutter run -d windows
