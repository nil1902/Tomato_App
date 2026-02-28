# Quick Troubleshooting Steps

Run these commands ONE BY ONE and tell me what you see:

## Step 1: Check Phone Connection
```bash
adb devices
```

**What you should see:**
```
List of devices attached
XXXXXXXXXX    device
```

**If you see "unauthorized"**: Check your phone for USB debugging popup
**If you see nothing**: Phone not connected properly

---

## Step 2: Check if APK was built
```bash
dir build\app\outputs\flutter-apk\app-debug.apk
```

**What you should see:**
```
app-debug.apk
```

**If file exists**: APK is ready, just need to install it

---

## Step 3: Force Install APK
```bash
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

**What you should see:**
```
Performing Streamed Install
Success
```

---

## Step 4: If Still Stuck - Manual Install

1. Open File Explorer
2. Go to: `C:\Users\HP\Desktop\zomato_app\build\app\outputs\flutter-apk\`
3. Find: `app-debug.apk`
4. Copy this file to your phone (via USB or send to yourself on WhatsApp)
5. On your phone, tap the APK file
6. Tap "Install"
7. If it says "Blocked", go to Settings > Security > Install unknown apps > Enable for your file manager

---

## Alternative: Use Windows to Copy APK

1. Connect phone via USB
2. On phone notification, tap "USB" and select "File Transfer"
3. Open "This PC" on Windows
4. Open your phone's storage
5. Copy `app-debug.apk` to phone's Download folder
6. On phone, open Files app > Downloads
7. Tap `app-debug.apk` to install

---

## What to Tell Me:

Run the commands above and tell me:
1. What does `adb devices` show?
2. Does the APK file exist?
3. What error do you see when trying to install?
