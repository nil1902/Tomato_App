# Google Sign-In Setup for Flutter Web

## The Error You're Seeing

```
ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag
```

This happens because Google Sign-In on web requires a Client ID to be configured.

## How to Fix It

### Step 1: Get Your Google OAuth Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google+ API** or **Google Identity Services**
4. Go to **APIs & Services** → **Credentials**
5. Click **Create Credentials** → **OAuth 2.0 Client ID**
6. Choose **Web application**
7. Add authorized JavaScript origins:
   - `http://localhost` (for local testing)
   - `http://localhost:8080`
   - Your production domain (e.g., `https://yourdomain.com`)
8. Add authorized redirect URIs:
   - `http://localhost`
   - `http://localhost:8080`
   - Your production domain
9. Click **Create**
10. Copy the **Client ID** (it looks like: `123456789-abc123.apps.googleusercontent.com`)

### Step 2: Add Client ID to Your App

Open `web/index.html` and replace `YOUR_GOOGLE_CLIENT_ID` with your actual Client ID:

```html
<meta name="google-signin-client_id" content="123456789-abc123.apps.googleusercontent.com">
```

### Step 3: Test It

1. Save the file
2. Stop your Flutter app (if running)
3. Run: `flutter run -d chrome`
4. Try Google Sign-In again

## Important Notes

- **Different Client IDs for Different Platforms**: You may need separate OAuth Client IDs for:
  - Web (JavaScript origins)
  - Android (SHA-1 fingerprint)
  - iOS (Bundle ID)

- **For Android**: Add your SHA-1 fingerprint to the OAuth client
- **For iOS**: Configure the iOS URL scheme in your Info.plist

## Troubleshooting

### Error: "redirect_uri_mismatch"
- Make sure your authorized redirect URIs include your current domain
- For local testing, add `http://localhost` and `http://localhost:8080`

### Error: "popup_closed_by_user"
- User cancelled the sign-in flow
- This is normal behavior

### Still Not Working?
- Clear browser cache
- Try incognito/private mode
- Check browser console for detailed errors
- Verify the Client ID is correct (no extra spaces)

## Alternative: Disable Google Sign-In for Web

If you don't want to set up Google Sign-In for web right now, you can disable it:

In `lib/services/auth_service.dart`, modify the constructor:

```dart
AuthService() {
  // Disable Google Sign-In on web for now
  if (kIsWeb) {
    _googleSignIn = null;
  } else {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    } catch (e) {
      debugPrint('⚠️ Google Sign-In initialization error: $e');
      _googleSignIn = null;
    }
  }
}
```

Then hide the Google Sign-In button on web platforms in your UI.
