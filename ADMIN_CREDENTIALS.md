# 🔐 Admin Panel Access

## Admin Credentials

**Primary Admin:**
<!-- Email: nilimeshpal15+admin@gmail.com
Password: Admin@12345 -->


**Secondary Admin:**
- **Email:** `admin@lovenest.com`  
- **Password:** `LoveNest@Admin2024!`

⚠️ **IMPORTANT:** These credentials provide FULL ACCESS to:
- All hotel data (create, read, update, delete)
- All user bookings and information
- User management and account control
- Database records and analytics

---

## Setup Instructions

### Step 1: Create Admin Account

The admin account has been registered. To activate it:

1. **Option A: Skip Email Verification (Development)**
   - Manually verify the admin email in your InsForge backend
   - Or use the backend admin panel to mark the email as verified

2. **Option B: Use Email Verification**
   - Check the email inbox for `admin@lovenest.com`
   - Enter the verification code when logging in

### Step 2: Add Admin Role to Database

Run this script to ensure the admin role is set:

```bash
dart run scripts/create_admin_user.dart
```

Or manually add the `role` column to `user_profiles` table if it doesn't exist:

```sql
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';
UPDATE user_profiles SET role = 'admin' WHERE email = 'admin@lovenest.com';
```

### Step 3: Access Admin Panel

1. Open your LoveNest app
2. Login with admin credentials
3. The app will detect the admin role and show the admin dashboard
4. Navigate to Settings → Admin Panel (visible only to admins)

---

## Admin Panel Features

### 🏨 Hotel Management
- View all hotels with detailed information
- Add new hotels with images and amenities
- Edit existing hotel details
- Delete or deactivate hotels
- Manage hotel ratings and reviews

### 📅 Booking Management
- View all bookings across the platform
- Filter by status (pending, confirmed, cancelled)
- View booking details and customer information
- Cancel or modify bookings
- Export booking reports

### 👥 User Management
- View all registered users
- See user profiles and activity
- Suspend or delete user accounts
- View user booking history
- Manage user roles

### 📊 Analytics Dashboard
- Total hotels and active listings
- Booking statistics (today, this week, this month)
- Revenue analytics
- Occupancy rates
- Popular destinations

### 🔧 System Settings
- Configure app settings
- Manage payment gateway settings
- Update terms and conditions
- Configure email templates

---

## Security Best Practices

1. **Change Default Password**
   - After first login, change the admin password
   - Use a strong, unique password

2. **Limit Admin Access**
   - Only share admin credentials with trusted team members
   - Create separate admin accounts for each administrator

3. **Monitor Admin Activity**
   - Regularly review admin actions
   - Check for unauthorized access

4. **Backup Data**
   - Regular database backups
   - Export important data periodically

---

## Troubleshooting

### Cannot Login
- Verify email address is correct
- Check if email verification is required
- Ensure password is exactly: `LoveNest@Admin2024!`

### Admin Panel Not Showing
- Check if `role` column exists in `user_profiles` table
- Verify role is set to 'admin' for your user
- Restart the app after role update

### Database Access Issues
- Verify access token is valid
- Check InsForge backend permissions
- Ensure RLS policies allow admin access

---

## Support

For admin panel issues or questions:
1. Check the app logs for error messages
2. Verify database schema matches requirements
3. Contact your development team for assistance

---

**Last Updated:** February 28, 2026  
**Version:** 1.0.0
