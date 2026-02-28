# 🎨 Admin Dashboard - Complete Guide

## Overview

Your new admin dashboard is designed with simplicity and power in mind - similar to Flipkart and Amazon admin panels. Every change you make updates in real-time for all users.

---

## 🚀 Quick Start

### Access Admin Panel

1. Login with admin credentials:
   - Email: `admin@lovenest.com`
   - Password: `LoveNest@Admin2024!`

2. Navigate to Profile → Admin Panel (or `/admin` route)

3. You'll see 6 main tabs:
   - **Dashboard** - Analytics and quick actions
   - **Hotels** - Manage all hotel listings
   - **Promotions** - Banners, popups, and discounts
   - **Bookings** - View and manage bookings
   - **Users** - User management
   - **Settings** - App configuration

---

## 📊 Dashboard Tab

### Real-time Statistics
- Total hotels count
- Total bookings
- Total users
- Today's bookings

### Quick Actions
- Add new hotel
- Create promotion
- Add banner
- Manage prices

### Recent Activity
- Live feed of recent actions
- Auto-refreshes every 30 seconds

---

## 🏨 Hotels Tab

### Features

**View Hotels**
- Grid or List view toggle
- Search by name or city
- Real-time filtering
- Pull to refresh

**Add New Hotel**
1. Tap the floating "Add Hotel" button
2. Fill in details:
   - Hotel name *
   - Description *
   - City *
   - Address *
   - Price per night *
   - Image URL *
   - Rating (slider 1-5)
   - Amenities (multi-select)
3. Tap "Add Hotel"
4. Changes appear instantly for all users

**Edit Hotel**
1. Tap the menu (⋮) on any hotel card
2. Select "Edit"
3. Modify any field
4. Tap "Update Hotel"
5. All users see the update immediately

**Delete Hotel**
1. Tap the menu (⋮) on any hotel card
2. Select "Delete"
3. Confirm deletion
4. Hotel removed from all user views instantly

### Real-time Updates
- Any change you make updates the database immediately
- All users see changes without refreshing
- No delay, no sync issues

---

## 🎯 Promotions Tab

### Three Sub-tabs

#### 1. Banners
**Add Banner**
- Title *
- Description
- Image URL *
- Click action link (optional)
- Active toggle

**Features**
- Show/hide with toggle switch
- Delete with confirmation
- Preview image in list
- Appears on user home screen instantly

#### 2. Popups
**Add Popup**
- Type: Discount, Announcement, or Welcome
- Title *
- Message *
- Image URL (optional)
- Button text
- Action link (optional)
- Active toggle

**Features**
- Show/hide with toggle
- Users see popup immediately when active
- Perfect for flash sales and announcements

#### 3. Discounts
**Add Discount**
- Coupon code * (e.g., WELCOME20)
- Description *
- Type: Percentage or Fixed amount
- Discount value *
- Minimum order amount
- Maximum discount (for percentage)
- Usage limit (optional)
- Valid from/to dates
- Active toggle

**Features**
- Users can apply coupons instantly
- Track usage in real-time
- Enable/disable anytime
- Set expiry dates

---

## 📅 Bookings Tab

### Features

**Filter Bookings**
- All bookings
- Confirmed
- Pending
- Cancelled

**View Details**
- Expand any booking to see full details
- Guest information
- Hotel details
- Check-in/out dates
- Total price
- Payment status

**Manage Bookings**
- Confirm booking (green button)
- Cancel booking (red button)
- Changes reflect immediately
- Users get instant updates

---

## 👥 Users Tab

### Features

**Search Users**
- Search by name or email
- Real-time filtering

**View User Details**
- Full name
- Email
- Phone
- Role (user/admin)
- User ID

**Manage Users**
- View details (popup)
- Make admin / Remove admin
- Delete user
- All changes instant

**Admin Badge**
- Purple badge for admin users
- Easy to identify admins

---

## ⚙️ Settings Tab

### App Configuration
- App name
- Currency settings
- Default language

### Payment Settings
- Payment gateway (Razorpay)
- Transaction fee percentage

### Policies
- Terms & Conditions
- Privacy Policy
- Cancellation Policy

### Notifications
- Email notifications
- Push notifications
- SMS notifications

### Database
- Backup database
- Clear cache

---

## 🎨 UI/UX Features

### Design Principles
✅ **Simple & Clean** - No clutter, easy navigation
✅ **Intuitive** - Self-explanatory actions
✅ **Fast** - Instant updates, no lag
✅ **Visual** - Icons, colors, clear labels
✅ **Mobile-friendly** - Works perfectly on all screens

### Color Coding
- 🔵 Blue - Information, hotels
- 🟢 Green - Success, active, confirm
- 🟠 Orange - Warnings, pending
- 🔴 Red - Errors, delete, cancel
- 🟣 Purple - Admin, special features

### Interactive Elements
- **Pull to Refresh** - Swipe down to reload
- **Search** - Real-time filtering
- **Toggle Switches** - Enable/disable instantly
- **Floating Action Button** - Quick add actions
- **Expansion Tiles** - Tap to see more details

---

## 🔄 Real-time Updates

### How It Works

Every action you take in the admin panel:
1. Updates the database immediately
2. All users see changes without refresh
3. No sync delays or conflicts

### Examples

**Add Hotel**
- You add a hotel → Database updated → All users see it instantly

**Change Price**
- You edit price → Database updated → All users see new price

**Add Discount**
- You create coupon → Database updated → Users can use it immediately

**Toggle Banner**
- You activate banner → Database updated → Banner appears on all devices

---

## 📱 Database Tables

Your admin panel manages these tables:

### Hotels Table
```
- id (UUID)
- name (text)
- description (text)
- city (text)
- address (text)
- price_per_night (numeric)
- image_url (text)
- rating (numeric)
- amenities (jsonb array)
- created_at (timestamp)
```

### Banners Table
```
- id (UUID)
- title (text)
- description (text)
- image_url (text)
- link (text)
- is_active (boolean)
- created_at (timestamp)
```

### Popups Table
```
- id (UUID)
- type (text)
- title (text)
- message (text)
- image_url (text)
- button_text (text)
- link (text)
- is_active (boolean)
- created_at (timestamp)
```

### Discounts Table
```
- id (UUID)
- code (text)
- description (text)
- discount_type (text)
- discount_value (numeric)
- min_order_amount (numeric)
- max_discount (numeric)
- usage_limit (integer)
- valid_from (timestamp)
- valid_to (timestamp)
- is_active (boolean)
- created_at (timestamp)
```

---

## 🛠️ Setup Required

### 1. Create Database Tables

Run these SQL commands in your InsForge backend:

```sql
-- Banners table
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  link TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Popups table
CREATE TABLE IF NOT EXISTS popups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  image_url TEXT,
  button_text TEXT DEFAULT 'Got it',
  link TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Discounts table
CREATE TABLE IF NOT EXISTS discounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  discount_type TEXT NOT NULL,
  discount_value NUMERIC NOT NULL,
  min_order_amount NUMERIC DEFAULT 0,
  max_discount NUMERIC,
  usage_limit INTEGER,
  valid_from TIMESTAMP,
  valid_to TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Enable Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE popups ENABLE ROW LEVEL SECURITY;
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;

-- Allow admins full access
CREATE POLICY "Admins can do everything on banners"
  ON banners FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admins can do everything on popups"
  ON popups FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admins can do everything on discounts"
  ON discounts FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Allow users to read active items
CREATE POLICY "Users can view active banners"
  ON banners FOR SELECT
  USING (is_active = true);

CREATE POLICY "Users can view active popups"
  ON popups FOR SELECT
  USING (is_active = true);

CREATE POLICY "Users can view active discounts"
  ON discounts FOR SELECT
  USING (is_active = true);
```

---

## 💡 Best Practices

### For Admins

1. **Test Before Activating**
   - Add items as inactive first
   - Review and test
   - Then activate for users

2. **Use Clear Descriptions**
   - Write clear, concise descriptions
   - Users should understand immediately

3. **Set Expiry Dates**
   - Always set end dates for promotions
   - Prevents outdated offers

4. **Monitor Activity**
   - Check dashboard regularly
   - Review booking trends
   - Respond to user needs

5. **Backup Regularly**
   - Use Settings → Backup Database
   - Export important data weekly

### For Promotions

1. **Banners**
   - Use high-quality images (1200x400px recommended)
   - Keep text minimal
   - Clear call-to-action

2. **Popups**
   - Don't overuse (users get annoyed)
   - Make them valuable (real discounts)
   - Short and sweet messages

3. **Discounts**
   - Use memorable codes (WELCOME20, SUMMER50)
   - Set reasonable limits
   - Test codes before sharing

---

## 🔐 Security

### Admin Access
- Only users with `role = 'admin'` can access
- All actions logged
- Secure API endpoints

### Data Protection
- Row Level Security enabled
- Admin-only write access
- Users can only read active items

---

## 📞 Support

### Common Issues

**Can't access admin panel?**
- Verify you're logged in as admin
- Check role in user_profiles table
- Restart app after role change

**Changes not appearing?**
- Check internet connection
- Pull to refresh
- Verify item is active

**Error adding items?**
- Check all required fields (*)
- Verify image URLs are valid
- Check database permissions

---

## 🎯 Next Steps

### Recommended Workflow

1. **Day 1: Setup**
   - Create database tables
   - Set up RLS policies
   - Test admin access

2. **Day 2: Add Content**
   - Add 5-10 hotels
   - Create 2-3 banners
   - Set up welcome popup

3. **Day 3: Promotions**
   - Create discount codes
   - Test coupon application
   - Monitor usage

4. **Ongoing**
   - Check dashboard daily
   - Respond to bookings
   - Update promotions weekly

---

## 🚀 Advanced Features (Coming Soon)

- Bulk hotel upload (CSV)
- Advanced analytics charts
- Email campaign builder
- Push notification sender
- Revenue reports
- User segmentation
- A/B testing for promotions

---

**Version:** 1.0.0  
**Last Updated:** February 28, 2026  
**Status:** Production Ready ✅

---

## 📝 Quick Reference

### Keyboard Shortcuts
- `Ctrl + R` - Refresh current tab
- `Ctrl + N` - Add new item (context-aware)
- `Ctrl + S` - Save changes
- `Ctrl + F` - Focus search

### Status Indicators
- 🟢 Active/Online
- 🟠 Pending/Warning
- 🔴 Inactive/Error
- 🔵 Info/Default

### Action Icons
- ➕ Add new
- ✏️ Edit
- 🗑️ Delete
- 👁️ View details
- 🔄 Refresh
- ⚙️ Settings

---

**Happy Managing! 🎉**

Your admin dashboard is now ready to manage your hotel booking platform like a pro. Every change you make updates instantly for all users - no delays, no complications. Just simple, powerful management.
