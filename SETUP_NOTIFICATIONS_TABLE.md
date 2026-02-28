# Setup Notifications Table

## Quick Setup Guide

Your app is trying to access a `notifications` table that doesn't exist yet in your InsForge database. Here's how to create it:

### Step 1: Access Your InsForge Database

You have two options:

**Option A: Use InsForge MCP Tool (Recommended)**
```
Use the InsForge MCP tool to run SQL directly
```

**Option B: Use InsForge Dashboard**
1. Go to your InsForge dashboard
2. Navigate to Database section
3. Open SQL Editor

### Step 2: Run This SQL

Copy and paste this SQL into your database:

```sql
-- Create notifications table
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Insert sample notifications for testing (optional)
INSERT INTO notifications (user_id, title, message, type, icon) VALUES
  ('f42a92cb-ccaa-4616-bd14-6936a926a5de', 'Welcome to LoveNest! 🎉', 'Thank you for joining us. Start exploring romantic getaways!', 'welcome', '🎉'),
  ('f42a92cb-ccaa-4616-bd14-6936a926a5de', 'Special Offer', 'Get 20% off on your first booking this weekend!', 'promotion', '🎁');
```

### Step 3: Verify Table Creation

Run this query to verify:

```sql
SELECT * FROM notifications LIMIT 5;
```

You should see the sample notifications (if you inserted them).

### Step 4: Test in Your App

1. Restart your Flutter app
2. Navigate to the Notifications screen
3. You should now see notifications without errors!

---

## Notification Types

The app supports these notification types:

- `welcome` - Welcome messages (🎉)
- `booking` - Booking confirmations (📅)
- `promotion` - Special offers (🎁)
- `reminder` - Booking reminders (⏰)
- `update` - Booking updates (📝)
- `system` - System messages (🔔)

---

## API Endpoints Used

Your app uses these endpoints:

- `GET /notifications?user_id=eq.{userId}` - Get user notifications
- `GET /notifications?user_id=eq.{userId}&is_read=eq.false` - Get unread count
- `PATCH /notifications?id=eq.{id}` - Mark as read
- `DELETE /notifications?id=eq.{id}` - Delete notification

---

## Troubleshooting

### Still getting 404 errors?

1. Make sure the table was created successfully
2. Check that your `api_constants.dart` has the correct base URL
3. Verify your database permissions allow table creation

### Need to reset the table?

```sql
DROP TABLE IF EXISTS notifications CASCADE;
-- Then run the CREATE TABLE script again
```

---

## Next: Enable Google Sign-In

See `SETUP_GOOGLE_SIGNIN.md` for instructions on configuring Google OAuth.
