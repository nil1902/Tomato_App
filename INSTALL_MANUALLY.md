# Install LoveNest App Manually (Easiest Way!)

The APK is already built! Just copy it to your phone and install.

## 📱 Step-by-Step Instructions:

### Method 1: USB File Transfer (Recommended)

1. **Keep your phone connected** via USB cable

2. **On your phone**: 
   - Swipe down from top
   - Tap the "USB" notification
   - Select **"File Transfer"** or **"Transfer files"**

3. **On your PC**:
   - Open **File Explorer** (Windows key + E)
   - You should see your phone listed (might be called "A015" or "CMF Phone 1")
   - Click on your phone

4. **Navigate on phone**:
   - Open **Internal storage**
   - Open **Download** folder

5. **On PC - Open another File Explorer window**:
   - Navigate to: `C:\Users\HP\Desktop\zomato_app\build\app\outputs\flutter-apk\`
   - Find the file: **app-debug.apk**
   - **Drag and drop** or **Copy** this file to your phone's Download folder

6. **On your phone**:
   - Open **Files** app (or File Manager)
   - Go to **Downloads**
   - Tap on **app-debug.apk**
   - Tap **Install**
   - If it says "Blocked" or "Install blocked":
     - Tap **Settings**
     - Enable **"Allow from this source"**
     - Go back and tap **Install** again
   - Wait 10 seconds
   - Tap **Open**

7. **Done!** The LoveNest app should open!

---

### Method 2: Send to Yourself (If USB doesn't work)

1. **On PC**:
   - Go to: `C:\Users\HP\Desktop\zomato_app\build\app\outputs\flutter-apk\`
   - Right-click **app-debug.apk**
   - Send it to yourself via:
     - **WhatsApp** (send to yourself)
     - **Telegram** (Saved Messages)
     - **Email** (send to your email)
     - **Google Drive** (upload and download on phone)

2. **On your phone**:
   - Download the APK file
   - Tap on it to install
   - Follow step 6 above

---

### Method 3: Use Windows Share

1. **On PC**:
   - Go to: `C:\Users\HP\Desktop\zomato_app\build\app\outputs\flutter-apk\`
   - Right-click **app-debug.apk**
   - Click **Share**
   - Select **Bluetooth** or **Nearby Share**
   - Send to your phone

2. **On your phone**:
   - Accept the file
   - Tap to install

---

## ⚠️ If You See "Install Blocked"

This is normal for apps not from Play Store!

**On CMF Phone 1 (Nothing OS)**:
1. When you see "Install blocked"
2. Tap **Settings** button
3. Enable **"Allow from this source"** or **"Install unknown apps"**
4. Go back
5. Tap **Install** again

**Or manually enable**:
1. Go to **Settings**
2. **Apps** > **Special app access**
3. **Install unknown apps**
4. Find **Files** or **Downloads**
5. Enable **"Allow from this source"**

---

## 🎉 After Installation

The app icon will appear on your home screen with a heart icon ❤️ and name "LoveNest"

Tap it to open!

---

## 🔧 If You Want to Try Flutter Run Again Later

After manually installing once, you can try:

```bash
flutter run -d 0011864CA002635
```

It might work better after the first manual install.

---

**The APK location again**: 
`C:\Users\HP\Desktop\zomato_app\build\app\outputs\flutter-apk\app-debug.apk`

Just copy this file to your phone and install it! 📱✨
