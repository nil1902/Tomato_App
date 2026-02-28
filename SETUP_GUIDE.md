# LoveNest - Setup & Configuration Guide

## ✅ What's Been Fixed

### 1. Project Renamed
- Changed from `zomato_app` to `lovenest`
- Updated all imports across the codebase
- Changed Android package name to `com.lovenest.app`

### 2. Authentication Persistence Fixed
- Added proper token storage and retrieval
- Splash screen now checks authentication status
- Users stay logged in between app restarts
- Added debug logging to track auth flow

### 3. Google Sign-In Implemented
- Added `google_sign_in` package
- Implemented OAuth flow with InsForge backend
- Login screen has working "Continue with Google" button
- Proper error handling and loading states

### 4. Dependencies Updated
```yaml
google_sign_in: ^6.2.1
jwt_decode: ^0.3.1
```

## 🔧 Required Setup Steps

### Step 1: Configure Google Sign-In for Android

You need to set up Google Sign-In in Google Cloud Console:

1. **Go to Google Cloud Console**: https://console.cloud.google.com/

2. **Create/Select Project**:
   - Create a new project or select existing one
   - Name it "LoveNest" or similar

3. **Enable Google Sign-In API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials**:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Select "Android" as application type
   
5. **Get SHA-1 Certificate Fingerprint**:
   ```bash
   # For debug builds (development)
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   
   Copy the SHA-1 fingerprint from the output.

6. **Configure OAuth Client**:
   - Package name: `com.lovenest.app`
   - SHA-1 certificate fingerprint: (paste the one you copied)
   - Click "Create"

7. **Download google-services.json**:
   - After creating credentials, download `google-services.json`
   - Place it in: `android/app/google-services.json`

8. **Update Android build.gradle**:
   Add to `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
   
   Add to `android/app/build.gradle.kts` (at the bottom):
   ```kotlin
   apply plugin: 'com.google.gms.google-services'
   ```

### Step 2: Configure InsForge Backend for Google OAuth

Your backend needs to support Google OAuth. Check with your InsForge backend:

1. Ensure Google OAuth is enabled in InsForge dashboard
2. Add your Google Client ID to InsForge OAuth settings
3. Verify the endpoint: `/api/auth/oauth/google` is available

### Step 3: Test the App

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on device/emulator
flutter run
```

## 🐛 Debugging Authentication Issues

### Check Auth Flow
The app now has debug logging. Look for these in console:

```
🔐 Auth Init - Token exists: true/false
🔐 Auth Init - User loaded: true/false
🔐 Login attempt for: user@example.com
🔐 Login response: 200
🔐 Login successful - User: user@example.com
🔐 Starting Google Sign-In...
🔐 Google Sign-In successful, authenticating with backend...
🔐 Backend response: 200
🔐 Google authentication successful - User: user@example.com
```

### Common Issues

**Issue**: "Google Sign-In cancelled by user"
- **Solution**: User cancelled the Google account picker. This is normal.

**Issue**: "Failed to get Google ID token"
- **Solution**: Check SHA-1 fingerprint is correctly configured in Google Cloud Console.

**Issue**: "Backend authentication failed"
- **Solution**: 
  - Verify InsForge backend supports Google OAuth
  - Check the endpoint `/api/auth/oauth/google` exists
  - Ensure Google Client ID is configured in InsForge

**Issue**: "Can't log in with same email after registration"
- **Solution**: This is now fixed! Tokens are properly saved and loaded on app restart.

## 📱 App Features Status

### ✅ Working
- Email/Password Registration
- Email/Password Login
- Google Sign-In (after setup)
- Authentication Persistence
- Splash Screen with Auth Check
- Profile Screen
- Logout

### 🚧 Next Steps (Not Yet Implemented)
- Hotel listing from database
- Hotel booking functionality
- Payment integration
- User profile editing
- Favorites/Wishlist
- Search & Filters
- Reviews & Ratings

## 🎨 UI/UX Improvements Made

1. **Modern Design**: Clean, romantic theme with heart icons
2. **Loading States**: Proper loading indicators on buttons
3. **Error Handling**: User-friendly error messages
4. **Smooth Animations**: Splash screen with fade/scale animations
5. **Dark Mode Support**: Automatic theme switching

## 📝 Next Development Steps

### Phase 1: Core Features
1. Create hotel database schema in InsForge
2. Implement hotel listing screen with real data
3. Add hotel details with images
4. Implement booking flow

### Phase 2: Enhanced Features
1. Add search and filters
2. Implement favorites
3. Add user reviews
4. Payment integration

### Phase 3: Polish
1. Add animations and transitions
2. Implement image caching
3. Add offline support
4. Performance optimization

## 🔐 Security Notes

- Never commit `google-services.json` to public repos
- Use environment variables for API keys in production
- Implement proper token refresh logic
- Add rate limiting on backend

## 📞 Support

If you encounter issues:
1. Check debug logs (🔐 prefix)
2. Verify InsForge backend is running
3. Ensure Google OAuth is properly configured
4. Check network connectivity

---

**Current Status**: Authentication is fully functional. Google Sign-In requires Google Cloud Console setup. Ready for hotel features implementation.
