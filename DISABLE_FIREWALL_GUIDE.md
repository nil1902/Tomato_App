# 🛡️ Disable Windows Firewall - Step by Step

## ⚠️ WARNING
This is for TESTING ONLY. Re-enable firewall after testing!

---

## Method 1: Using Windows Security (Easiest)

### Step 1: Open Windows Security
- Press `Windows Key` + `I` to open Settings
- Click on **"Privacy & Security"** (Windows 11) or **"Update & Security"** (Windows 10)
- Click on **"Windows Security"**
- Click on **"Open Windows Security"**

### Step 2: Disable Firewall
- Click on **"Firewall & network protection"**
- You'll see 3 network types:
  - Domain network
  - Private network (most common)
  - Public network
- Click on **"Private network"** (the one that says "Active")
- Toggle **"Microsoft Defender Firewall"** to **OFF**
- Click **Yes** on the confirmation dialog

### Step 3: Test Your App
```bash
flutter run -d windows
```

### Step 4: Re-enable Firewall (IMPORTANT!)
- Go back to the same screen
- Toggle **"Microsoft Defender Firewall"** to **ON**

---

## Method 2: Using PowerShell (Quick)

### Disable Firewall
1. Press `Windows Key` + `X`
2. Click **"Windows PowerShell (Admin)"** or **"Terminal (Admin)"**
3. Run this command:

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

### Test Your App
```bash
flutter run -d windows
```

### Re-enable Firewall (IMPORTANT!)
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

---

## Method 3: Using Control Panel

### Step 1: Open Firewall Settings
- Press `Windows Key` + `R`
- Type: `firewall.cpl`
- Press Enter

### Step 2: Disable Firewall
- Click **"Turn Windows Defender Firewall on or off"** (left sidebar)
- Select **"Turn off Windows Defender Firewall"** for:
  - Private network settings
  - Public network settings
- Click **OK**

### Step 3: Test Your App
```bash
flutter run -d windows
```

### Step 4: Re-enable Firewall
- Go back to the same screen
- Select **"Turn on Windows Defender Firewall"** for both
- Click **OK**

---

## Quick Batch Script

I'll create a script to toggle firewall easily:

Save this as `toggle_firewall.bat`:

```batch
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
```

---

## After Disabling Firewall

### Test Your App
```bash
cd C:\Users\HP\Desktop\zomato_app
flutter run -d windows
```

### If It Works Now
The issue was definitely the firewall. You have 2 options:

**Option A: Keep Using Web Version**
```bash
flutter run -d chrome
```

**Option B: Add Firewall Exception (Better)**
1. Re-enable firewall
2. Run your app
3. When Windows asks, click "Allow access"

---

## Troubleshooting

### "Access Denied" Error
- Right-click PowerShell/CMD
- Select **"Run as Administrator"**
- Try again

### Can't Find Windows Security
- Press `Windows Key`
- Type: `Windows Security`
- Click the app

### Still Not Working After Disabling Firewall?
The issue might not be firewall. Check:
1. Internet connection
2. Antivirus software
3. VPN settings
4. Proxy settings

---

## Important Reminders

✅ **DO:**
- Disable only for testing
- Re-enable immediately after
- Use on private network only

❌ **DON'T:**
- Leave firewall disabled
- Disable on public WiFi
- Forget to re-enable

---

## Alternative: Just Use Chrome

Instead of dealing with firewall:

```bash
flutter run -d chrome
```

Chrome version works perfectly and doesn't need firewall changes!

---

## Quick Commands Summary

```powershell
# Disable firewall (Admin PowerShell)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Run your app
flutter run -d windows

# Enable firewall (IMPORTANT!)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

---

**Easiest Solution:** Just use Chrome instead! 🌐
```bash
flutter run -d chrome
```
