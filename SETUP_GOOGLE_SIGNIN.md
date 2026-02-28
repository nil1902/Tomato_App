# Setup Google Sign-In

## Current Status

Google Sign-In is currently **DISABLED** to prevent errors. Here's how to enable it:

---

## Step 1: Create Google OAuth Credentials

### 1.1 Go to Google Cloud Console
Visit: https://console.cloud.google.com/

### 1.2 Create or Select Project
- Create a new project or select your existing one
- Name it something like "LoveNest App"

### 1.3 Enable Google Sign-In API
1. Go to "APIs & Services" > "Library"
2. Search for "Google Sign-In API" or "Google+ API"
3. Click "Enable"

### 1.4 Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "Web application"
4. Add authorized JavaScript origins:
   - `http://localhost` (for local testing)
   - `http://localhost:8080`
   - Your production domain (e.g., `https://yourdomain.com`)
5. Click "Create"
6. **Copy the Client ID** - you'll need this!

---

## Step 2: Configure Your Flutter App

### 2.1 Update web/index.html

Replace this line:
```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
```

With your actual Client ID:
```html
<meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
```

### 2.2 Enable Google Sign-In in AuthService

In `lib/services/auth_service.dart`, replace the constructor:

```dart
AuthService() {
  // Initialize Google Sign-In for all platforms
  try {
    if (kIsWeb) {
      // For web, clientId is read from meta tag in index.html
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    } else {
      // For mobile platforms - add your client ID here
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // For Android, add: clientId: 'YOUR_ANDROID_CLIENT_ID',
        // For iOS, configure in Info.plist
      );
    }
    debugPrint('✅ Google Sign-In initialized');
  } catch (e) {
    debugPrint('⚠️ Google Sign-In initialization error: $e');
    _googleSignIn = null;
  }
}
```

---

## Step 3: Configure for Mobile (Optional)

### For Android:

1. Get Android OAuth Client ID from Google Cloud Console
2. Add to `android/app/build.gradle`:
```gradle
defaultConfig {
    // ... other config
    resValue "string", "default_web_client_id", "YOUR_WEB_CLIENT_ID"
}
```

### For iOS:

1. Get iOS OAuth Client ID from Google Cloud Console
2. Add to `ios/Runner/Info.plist`:
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID</string>
```

---

## Step 4: Test Google Sign-In

1. Rebuild your app: `flutter run`
2. Go to Login screen
3. Click "Sign in with Google"
4. You should see the Google Sign-In popup!

---

## Troubleshooting

### Error: "popup_closed_by_user"
- User cancelled the sign-in flow
- This is normal behavior

### Error: "idpiframe_initialization_failed"
- Check that your Client ID is correct in `web/index.html`
- Verify authorized JavaScript origins in Google Cloud Console

### Error: "redirect_uri_mismatch"
- Add your domain to authorized redirect URIs in Google Cloud Console

### Still not working?
- Clear browser cache
- Check browser console for detailed errors
- Verify Google Sign-In API is enabled

---

## Alternative: Keep Google Sign-In Disabled

If you don't need Google Sign-In right now:

1. Keep the current code (it's already disabled)
2. Hide the "Sign in with Google" button in your UI
3. Users can still register/login with email/password

---

## Security Notes

- Never commit your Client ID to public repositories
- Use environment variables for production
- Restrict your OAuth credentials to specific domains
- Regularly rotate credentials if compromised

---

## Next Steps

After enabling Google Sign-In:
1. Test the complete auth flow
2. Verify user profiles are created correctly
3. Test on different browsers
4. Deploy to production with production credentials
