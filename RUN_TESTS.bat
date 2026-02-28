@echo off
echo ========================================
echo   LOVENEST - AUTOMATED TESTING
echo ========================================
echo.
echo Running automated authentication tests...
echo.

REM Run the automated test script
dart test_all.dart

echo.
echo ========================================
echo Running Flutter unit tests...
echo ========================================
echo.

REM Run Flutter tests
flutter test test/auth_test.dart

echo.
echo ========================================
echo   TESTING COMPLETE
echo ========================================
echo.
pause
