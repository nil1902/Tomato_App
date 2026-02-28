# Error Fixes Guide

## Issues Identified

### 1. 404 Error - Notifications Table Missing ❌
**Error**: `GET https://nukpc39r.ap-southeast.insforge.app/notifications 404 (Not Found)`

**Cause**: The `notifications` table doesn't exist in your InsForge database.

**Fix**: Create the notifications table in your database.

### 2. Google Sign-In Configuration Missing ❌
**Error**: `ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag`

**Cause**: The Google Client ID in `web/index.html` is a placeholder.

**Fix**: Replace with your actual Google OAuth Client ID.

### 3. Image Assertion Error ❌
**Error**: `Assertion failed: file:///C:/src/flutter/packages/flutter/lib/src/widgets/image.dart:545:10`

**Cause**: An image widget is trying to load an invalid or null image URL.

**Fix**: Add null checks and fallback images.

### 4. Layout Overflow ⚠️
**Error**: `A RenderFlex overflowed by 3.2 pixels on the right`

**Cause**: UI layout constraint issue (minor).

**Fix**: Adjust widget constraints or use flexible layouts.

---

## Solutions

### Solution 1: Create Notifications Table

You need to create the `notifications` table in your InsForge database. Run this SQL:

```sql
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  icon TEXT DEFAULT '🔔',
  is_read BOOLEAN DEFAULT FALSE,
  data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

### Solution 2: Fix Google Sign-In Configuration

**Option A: Get Your Google OAuth Client ID**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials
5. Add authorized JavaScript origins (your web domain)
6. Copy the Client ID

**Option B: Disable Google Sign-In (Temporary)**

If you don't need Google Sign-In right now, you can disable it temporarily.

### Solution 3: Fix Image Loading Issues

The app needs better error handling for images. This is likely in hotel cards or profile avatars.

### Solution 4: Fix Layout Overflow

Minor UI adjustment needed in notification cards or other widgets.

---

## Quick Fixes to Apply Now

### 1. Disable Google Sign-In Temporarily (Immediate Fix)

This will stop the Google Sign-In error until you configure it properly.

### 2. Add Graceful Fallback for Notifications

Make the notifications screen work even when the table doesn't exist yet.

### 3. Add Image Error Handling

Prevent crashes when images fail to load.

---

## Next Steps

1. **Create the notifications table** using the SQL above
2. **Configure Google OAuth** or disable it temporarily
3. **Apply the code fixes** I'll provide next
4. **Test the app** to verify all errors are resolved

Would you like me to:
- A) Apply the code fixes to disable Google Sign-In temporarily?
- B) Apply the code fixes to handle missing notifications table gracefully?
- C) Both A and B?
- D) Help you set up the notifications table in InsForge?
