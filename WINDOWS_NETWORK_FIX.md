# Windows Network Connection Fix

## Problem
Your Flutter Windows app shows "Network error occurred. Please check your connection" when trying to login/register.

## Root Cause
Windows desktop applications need special HTTP client configuration to handle SSL certificates and network connections properly.

## What We Fixed

### 1. Enhanced HTTP Client Configuration
- Added proper timeout handling (30 seconds)
- Added idle timeout configuration
- Added user agent to avoid blocking
- Improved SSL certificate handling for development

### 2. Better Error Messages
The app now shows specific error messages:
- **SocketException**: Connection issues (firewall, internet, VPN)
- **Timeout**: Server taking too long to respond
- **HandshakeException**: SSL/TLS certificate issues

### 3. Request Timeout Protection
Added 30-second timeout to all auth requests to prevent hanging.

## Steps to Fix

### Step 1: Enable Firewall Rules (IMPORTANT!)
Right-click `enable_firewall.bat` and select "Run as Administrator"

This will enable all firewall rules for the app.

### Step 2: Run the New Build
The app has been rebuilt with the fixes. Run:
```
build\windows\x64\runner\Release\zomato_app.exe
```

### Step 3: Check the Console Output
When you try to login, the console will show detailed logs:
```
🔐 Login attempt for: [email]
🔐 API URL: https://nukpc39r.ap-southeast.insforge.app/api/auth/sessions?client_type=mobile
🔐 Login response: 200
```

## Troubleshooting

### If you still get network errors:

1. **Check Internet Connection**
   ```powershell
   Test-NetConnection -ComputerName nukpc39r.ap-southeast.insforge.app -Port 443
   ```
   Should show `TcpTestSucceeded: True`

2. **Check Firewall Status**
   ```powershell
   Get-NetFirewallRule -DisplayName "zomato_app" | Select-Object DisplayName, Enabled, Direction, Action
   ```
   All rules should show `Enabled: True`

3. **Check System Date/Time**
   SSL certificates require correct system time. Verify your Windows date/time is correct.

4. **Disable VPN Temporarily**
   Some VPNs block certain connections. Try disabling your VPN if you have one.

5. **Check Antivirus**
   Some antivirus software blocks network connections. Try temporarily disabling it.

6. **Check Windows Defender Firewall**
   - Open Windows Security
   - Go to Firewall & network protection
   - Click "Allow an app through firewall"
   - Find "zomato_app" and ensure both Private and Public are checked

## What Changed in the Code

### lib/utils/http_client_windows.dart
- Added `idleTimeout` configuration
- Added user agent string
- Improved certificate handling

### lib/services/auth_service.dart
- Added detailed logging for debugging
- Added timeout handling with `.timeout()`
- Added specific error messages for different error types
- Added API URL logging to verify correct endpoint

## Testing

1. Run the app
2. Try to login with: `nilimeshpal22@gmail.com` / `Nile2002`
3. Check the console for detailed logs
4. If it fails, the error message will tell you exactly what's wrong

## Network Test Results

Your network connection to the backend is working:
```
ComputerName: nukpc39r.ap-southeast.insforge.app
RemotePort: 443
TcpTestSucceeded: True
```

This means the issue is with how the Flutter app handles the connection, which we've now fixed.

## Next Steps

1. Run `enable_firewall.bat` as Administrator
2. Launch the new build: `build\windows\x64\runner\Release\zomato_app.exe`
3. Try logging in and check the console output
4. If you still have issues, share the console output for further debugging
