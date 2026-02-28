# 🚀 Quick Guide: Insert 20 Hotels in 3 Steps

## Problem
You can't see hotels in your app because they haven't been inserted into the database yet.

## Solution (3 Easy Steps)

### Step 1: Get Your Access Token (30 seconds)

1. Run your app: `flutter run`
2. Login with your account
3. Look at the console - you'll see:
   ```
   🔑 ACCESS TOKEN FOR HOTEL INSERTION:
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI...
   ```
4. Copy the entire token (the long string)

### Step 2: Update the Script (10 seconds)

1. Open `scripts/insert_hotels.dart`
2. Line 12: Replace `'YOUR_ACCESS_TOKEN'` with your copied token
3. Save the file

### Step 3: Run the Script (5 seconds)

```bash
dart run scripts/insert_hotels.dart
```

Done! You'll see:
```
✅ SUCCESS! Inserted 15 hotels
```

## Want 20 Hotels Instead of 15?

The current script has 15 hotels. To add 5 more, I can:

1. **Option A**: Create a new script with all 20 hotels
2. **Option B**: Run the current script (15 hotels) and add 5 more later

**Recommendation**: Start with 15 hotels now, then add more if needed.

## Verify Hotels Are Inserted

1. Restart your app
2. Go to Home screen
3. You should see all 15 hotels with:
   - Hotel names
   - Images
   - Prices
   - Ratings
   - Locations

## Troubleshooting

### "Failed to insert hotels"
- Check your access token is correct
- Make sure you're logged in
- Token expires after some time - get a fresh one

### "No hotels showing in app"
- Restart the app completely
- Check your internet connection
- Verify the script ran successfully

### "Access token not showing in console"
- Make sure you logged in (not just registered)
- Check `lib/services/auth_service.dart` line 122-125

## Hotel Categories Included

The 15 hotels cover:
- ✨ 3 Luxury Hotels (₹15,000-₹25,000/night)
- 🏛️ 2 Boutique Hotels (₹8,500-₹9,500/night)
- 🏨 3 Mid-Range Hotels (₹5,500-₹7,500/night)
- 💰 2 Budget Hotels (₹2,800-₹3,500/night)
- 🌟 5 Unique Hotels (₹10,000-₹14,000/night)

## Locations Covered

- Udaipur, Goa, Manali (Luxury)
- Jaipur, Pondicherry (Boutique)
- Ooty, Nainital, Mumbai (Mid-range)
- Bangalore, Shimla (Budget)
- Wayanad, Jaisalmer, Alleppey, Nashik, Darjeeling (Unique)

---

**Need help?** Check `INSERT_HOTELS_GUIDE.md` for detailed instructions.
