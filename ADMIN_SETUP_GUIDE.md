# 🔐 Admin Panel Setup Guide

## Your Admin Account

**Email:** `nilimeshpal15@gmail.com`  
**Password:** Your existing password

---

## Quick Setup (3 Steps)

### Step 1: Login to Your App

1. Open your LoveNest app
2. Login with your email: `nilimeshpal15@gmail.com`
3. Use your existing password

### Step 2: Get Your Access Token

After logging in, check the console output. You'll see something like:

```
═══════════════════════════════════════════════════════════════
🔑 ACCESS TOKEN FOR HOTEL INSERTION:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
═══════════════════════════════════════════════════════════════
```

Copy this token.

### Step 3: Set Admin Role

Run this command and paste your token when prompted:

```bash
dart run scripts/set_admin_role.dart
```

The script will:
- Verify your account
- Set your role to 'admin'
- Grant you full admin access

---

## Alternative Method: Manual SQL

If the script doesn't work, run this SQL in your InsForge database:

```sql
-- Add role column (if it doesn't exist)
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- Set your account as admin
UPDATE user_profiles SET role = 'admin' WHERE email = 'nilimeshpal15@gmail.com';
```

---

## Accessing Admin Panel

Once admin role is set:

1. **Restart your app**
2. **Login** with your credentials
3. **Go to Settings** (bottom navigation)
4. **Look for "Admin Panel"** option (only visible to admins)
5. **Click to access** full admin dashboard

---

## Admin Panel Features

### 🏨 Hotel Management
- **View All Hotels**: See complete list with details
- **Add New Hotel**: Create hotels with images, amenities, location
- **Edit Hotels**: Update any hotel information
- **Delete Hotels**: Remove hotels from platform
- **Manage Status**: Activate/deactivate hotels

### 📅 Booking Management
- **View All Bookings**: See every booking on the platform
- **Filter by Status**: pending, confirmed, cancelled, completed
- **Booking Details**: Customer info, dates, payment status
- **Modify Bookings**: Change dates, cancel, refund
- **Export Reports**: Download booking data

### 👥 User Management
- **View All Users**: Complete user list with profiles
- **User Details**: See booking history, preferences
- **Account Actions**: Suspend, delete, or restore accounts
- **Role Management**: Promote users to admin
- **Activity Logs**: Track user actions

### 📊 Analytics Dashboard
- **Real-time Stats**: Hotels, bookings, users, revenue
- **Today's Activity**: New bookings, registrations
- **Trends**: Weekly/monthly performance
- **Popular Hotels**: Most booked properties
- **Revenue Reports**: Financial overview

### ⚙️ System Settings
- **App Configuration**: Update app settings
- **Payment Settings**: Razorpay configuration
- **Email Templates**: Customize notifications
- **Terms & Policies**: Update legal documents

---

## Admin Capabilities

✅ **Full Database Access**
- Read, write, update, delete any record
- Direct database queries
- Bulk operations

✅ **User Data Management**
- View all user information
- Access booking history
- Manage user accounts

✅ **Content Management**
- Hotel listings
- Images and media
- Descriptions and details

✅ **Financial Operations**
- View all transactions
- Process refunds
- Generate reports

---

## Security Best Practices

### 1. Protect Your Credentials
- Never share your admin password
- Use a strong, unique password
- Enable 2FA if available

### 2. Monitor Admin Activity
- Regularly check admin logs
- Review recent changes
- Watch for suspicious activity

### 3. Limit Admin Access
- Only grant admin to trusted team members
- Create separate admin accounts (don't share)
- Revoke access when no longer needed

### 4. Regular Backups
- Backup database regularly
- Export important data
- Keep offline copies

### 5. Audit Trail
- Document major changes
- Keep records of deletions
- Review user complaints

---

## Troubleshooting

### "Admin Panel" not showing in Settings

**Solution:**
1. Verify role is set to 'admin' in database
2. Restart the app completely
3. Clear app cache if needed
4. Re-login to refresh permissions

### Cannot access certain features

**Solution:**
1. Check your access token is valid
2. Verify database permissions
3. Check InsForge RLS policies
4. Ensure admin role is properly set

### Database errors when making changes

**Solution:**
1. Check InsForge backend is running
2. Verify API endpoints are correct
3. Check network connection
4. Review error logs for details

### Token expired errors

**Solution:**
1. Logout and login again
2. Get fresh access token
3. Update token in admin service
4. Check token expiration settings

---

## Getting Help

### Check Logs
- App console output
- Network requests
- Error messages

### Verify Setup
- Database schema correct
- Role column exists
- Admin role is set
- Access token valid

### Contact Support
- Review documentation
- Check GitHub issues
- Contact development team

---

## Next Steps After Setup

1. ✅ **Verify Access**: Login and check admin panel appears
2. ✅ **Test Features**: Try viewing hotels, bookings, users
3. ✅ **Add Test Data**: Create a test hotel to verify CRUD works
4. ✅ **Review Analytics**: Check dashboard stats are loading
5. ✅ **Configure Settings**: Update app configuration as needed

---

## Important Notes

⚠️ **Admin Power**: You have full control over the platform. Use responsibly.

⚠️ **Data Safety**: Always backup before bulk operations or deletions.

⚠️ **User Privacy**: Respect user data and privacy regulations.

⚠️ **Testing**: Test changes in development before production.

---

**Setup Date:** February 28, 2026  
**Admin Email:** nilimeshpal15@gmail.com  
**Version:** 1.0.0
