# 📱 Android Build Guide - CMF Phone 1

## ✅ Configuration Complete

Your app is configured for:
- **Target Device:** CMF Phone 1
- **Android Version:** Android 16 (API 35)
- **Minimum Android:** Android 7.0 (API 24)
- **Package Name:** com.lovenest.app
- **App Name:** LoveNest

---

## 🚀 Build APK

### Option 1: Use Build Script (Easiest)
```bash
build_android.bat
```

### Option 2: Manual Commands
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📦 APK Location

After building, find your APK at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 Install on CMF Phone 1

### Step 1: Transfer APK
**Method A: USB Cable**
1. Connect phone to PC via USB
2. Copy `app-release.apk` to phone's Downloads folder

**Method B: Cloud Storage**
1. Upload APK to Google Drive/Dropbox
2. Download on phone

**Method C: Direct Install (if phone connected)**
```bash
flutter install
```

### Step 2: Enable Unknown Sources
1. Open **Settings**
2. Go to **Security & Privacy**
3. Enable **Install Unknown Apps**
4. Allow installation from **Files** or **Chrome**

### Step 3: Install APK
1. Open **Files** app
2. Navigate to **Downloads**
3. Tap **app-release.apk**
4. Tap **Install**
5. Tap **Open** when done

---

## ✨ Features Working on Android

All features from web version work perfectly:

### Authentication ✅
- Email/Password login
- Registration
- Email verification
- Password reset
- Google Sign-In
- Profile management

### Hotel Booking ✅
- Browse hotels
- Search & filter
- Hotel details
- Image gallery
- Amenities list
- Reviews & ratings
- Booking flow
- Payment integration

### User Features ✅
- Profile editing
- Booking history
- Wishlist
- Notifications
- Coupons
- Loyalty points
- Chat support
- AI assistant

### Admin Features ✅
- Admin dashboard
- Hotel management
- Booking management
- User management
- Promotions & banners
- Discount codes
- Analytics

---

## 🎨 Android-Specific Features

### Material Design 3
- Native Android UI
- Smooth animations
- Gesture navigation
- Dark mode support

### Performance
- Fast startup
- Smooth scrolling
- Optimized images
- Efficient memory usage

### Permissions
- Internet access ✅
- Network state ✅
- Storage (for images) ✅
- Camera (for profile pics) ✅

---

## 🔧 Build Variants

### Debug Build (for testing)
```bash
flutter build apk --debug
```
- Larger file size
- Includes debugging info
- Hot reload support

### Release Build (for distribution)
```bash
flutter build apk --release
```
- Smaller file size
- Optimized performance
- No debugging info

### Split APKs (smaller downloads)
```bash
flutter build apk --split-per-abi
```
Creates separate APKs for:
- arm64-v8a (most phones)
- armeabi-v7a (older phones)
- x86_64 (emulators)

---

## 📊 APK Size

**Expected Sizes:**
- Release APK: ~40-50 MB
- Debug APK: ~60-70 MB
- Split APKs: ~20-25 MB each

---

## 🧪 Testing on CMF Phone 1

### Before Installing
1. ✅ Android 16 compatible
2. ✅ Internet connection
3. ✅ 100MB free space
4. ✅ Unknown sources enabled

### After Installing
Test these features:
- [ ] App launches
- [ ] Login works
- [ ] Hotels load
- [ ] Images display
- [ ] Booking works
- [ ] Payment works
- [ ] Notifications work
- [ ] Camera works (profile pic)
- [ ] Location works (if used)

---

## 🐛 Troubleshooting

### "App not installed"
**Solution:** Uninstall old version first
```bash
adb uninstall com.lovenest.app
```

### "Parse error"
**Solution:** APK corrupted, rebuild
```bash
flutter clean
flutter build apk --release
```

### "Insufficient storage"
**Solution:** Free up space (need 100MB)

### App crashes on launch
**Solution:** Check Android version
- Minimum: Android 7.0
- Target: Android 16

---

## 📱 Device Compatibility

### CMF Phone 1 Specs
- **OS:** Android 16
- **RAM:** 6GB/8GB
- **Storage:** 128GB/256GB
- **Display:** 6.67" AMOLED
- **Processor:** MediaTek Dimensity

### App Requirements
- **Minimum:** Android 7.0 (API 24)
- **Target:** Android 16 (API 35)
- **RAM:** 2GB minimum
- **Storage:** 100MB
- **Internet:** Required

---

## 🚀 Advanced Build Options

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### Build with Obfuscation
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### Build for Specific ABI
```bash
flutter build apk --release --target-platform android-arm64
```

---

## 📝 Version Management

### Update Version
Edit `android/app/build.gradle.kts`:
```kotlin
versionCode = 2  // Increment for each release
versionName = "1.0.1"  // User-visible version
```

### Build with Version
```bash
flutter build apk --release --build-name=1.0.1 --build-number=2
```

---

## 🔐 Signing (for Play Store)

### Generate Keystore
```bash
keytool -genkey -v -keystore lovenest-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lovenest
```

### Configure Signing
Create `android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=lovenest
storeFile=lovenest-key.jks
```

### Build Signed APK
```bash
flutter build apk --release
```

---

## 📤 Distribution

### Direct Install
- Share APK file
- Users install manually
- No Play Store needed

### Google Play Store
1. Create developer account ($25)
2. Build app bundle
3. Upload to Play Console
4. Fill app details
5. Submit for review

### Alternative Stores
- Amazon Appstore
- Samsung Galaxy Store
- Huawei AppGallery

---

## 🎯 Performance Tips

### Optimize Images
- Use WebP format
- Compress images
- Lazy load images

### Reduce APK Size
- Remove unused resources
- Enable ProGuard
- Use split APKs

### Improve Startup
- Minimize splash screen
- Lazy load features
- Cache data locally

---

## 📊 Analytics

### Track Installs
- Google Analytics
- Firebase Analytics
- Custom tracking

### Monitor Crashes
- Firebase Crashlytics
- Sentry
- Custom error reporting

---

## 🔄 Updates

### Over-the-Air Updates
- CodePush
- Firebase Remote Config
- Custom update system

### Play Store Updates
- Automatic updates
- Staged rollouts
- Beta testing

---

## ✅ Pre-Launch Checklist

- [ ] Build APK successfully
- [ ] Test on CMF Phone 1
- [ ] All features working
- [ ] No crashes
- [ ] Good performance
- [ ] Proper permissions
- [ ] App icon set
- [ ] Splash screen works
- [ ] Deep links work
- [ ] Push notifications work

---

## 🎉 Ready to Build!

Run this command:
```bash
build_android.bat
```

Or:
```bash
flutter build apk --release
```

Your APK will be ready in 2-3 minutes!

---

**App Details:**
- **Name:** LoveNest
- **Package:** com.lovenest.app
- **Version:** 1.0.0
- **Target:** Android 16
- **Size:** ~45 MB

**Install on CMF Phone 1 and enjoy!** 🚀
