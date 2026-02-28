# Resend Verification Code - Debug & Fix

## Problem
Verification code resend fail ho raha tha without proper error messages.

## Changes Made

### 1. Enhanced Auth Service Logging (`lib/services/auth_service.dart`)

**Added detailed debug logs:**
```dart
Future<bool> resendVerificationEmail({required String email}) async {
  try {
    debugPrint('🔐 Resending verification email to: $email');
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/email/send-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    
    debugPrint('🔐 Resend response: ${response.statusCode}');
    debugPrint('🔐 Resend body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('🔐 Verification email sent successfully');
      return true;
    } else {
      debugPrint('🔐 Resend failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    debugPrint('🔐 Resend Verification Error: $e');
    return false;
  }
}
```

**What it does:**
- Logs email being sent to
- Logs HTTP response status code
- Logs response body for debugging
- Logs success/failure clearly

### 2. Better Error Handling in Verification Screen (`lib/screens/verify_email_screen.dart`)

**Updated `_sendVerificationCode()` method:**
```dart
Future<void> _sendVerificationCode() async {
  try {
    final auth = context.read<AuthService>();
    final success = await auth.resendVerificationEmail(email: widget.email);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Error sending verification code: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**What it does:**
- Shows green snackbar on success
- Shows red snackbar on failure
- Shows network error message on exception
- Proper try-catch error handling

**Updated Resend Button:**
```dart
TextButton(
  onPressed: isResending ? null : () async {
    setState(() => isResending = true);
    try {
      await _sendVerificationCode();
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  },
  child: isResending ? CircularProgressIndicator() : Text('Resend'),
)
```

**What it does:**
- Uses try-finally to ensure loading state is reset
- Prevents multiple simultaneous resend requests
- Shows loading indicator during resend

## How to Debug

### Step 1: Check Console Logs
When you click "Resend", check the console for these logs:
```
🔐 Resending verification email to: user@example.com
🔐 Resend response: 200
🔐 Resend body: {"message":"Verification email sent"}
🔐 Verification email sent successfully
```

### Step 2: Common Issues & Solutions

#### Issue 1: Network Error
**Logs show:**
```
🔐 Resend Verification Error: SocketException: Failed host lookup
```
**Solution:** Check internet connection

#### Issue 2: 404 Not Found
**Logs show:**
```
🔐 Resend response: 404
🔐 Resend body: {"error":"Endpoint not found"}
```
**Solution:** Check API endpoint URL in `api_constants.dart`

#### Issue 3: 400 Bad Request
**Logs show:**
```
🔐 Resend response: 400
🔐 Resend body: {"error":"Email not found"}
```
**Solution:** User might not be registered, or email is wrong

#### Issue 4: 429 Too Many Requests
**Logs show:**
```
🔐 Resend response: 429
🔐 Resend body: {"error":"Rate limit exceeded"}
```
**Solution:** Wait a few minutes before trying again

#### Issue 5: 500 Server Error
**Logs show:**
```
🔐 Resend response: 500
🔐 Resend body: {"error":"Internal server error"}
```
**Solution:** Backend issue, contact backend team

## Testing Steps

1. **Open app and go to verification screen**
2. **Click "Resend" button**
3. **Check console logs** for debug messages
4. **Check snackbar message:**
   - Green = Success
   - Red = Failed
5. **Check email inbox** for verification code

## API Endpoint

**Endpoint:** `POST /api/auth/email/send-verification`

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200/201):**
```json
{
  "message": "Verification email sent"
}
```

**Error Response (4xx/5xx):**
```json
{
  "error": "Error message here"
}
```

## User Feedback

### Success:
- ✅ Green snackbar: "Verification code sent to your email!"
- ✅ Loading indicator disappears
- ✅ User can check email

### Failure:
- ❌ Red snackbar: "Failed to send code. Please try again."
- ❌ Loading indicator disappears
- ❌ User can try again

### Network Error:
- ❌ Red snackbar: "Network error. Please check your connection."
- ❌ Loading indicator disappears
- ❌ User should check internet

## Next Steps

1. **Run the app**
2. **Try to resend verification code**
3. **Check console logs** to see exact error
4. **Share the logs** if issue persists

The enhanced logging will help identify the exact problem! 🔍
