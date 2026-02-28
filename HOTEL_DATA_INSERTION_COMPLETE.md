# ✅ Hotel Data Insertion - Ready to Go!

## 🎯 What's Been Prepared

I've created a complete system to insert 15 dummy hotels into your database with full details across all categories.

## 📦 Files Created

1. **scripts/insert_hotels.dart** - Main insertion script (ready to run)
2. **scripts/hotels_data.json** - All 15 hotels in JSON format
3. **scripts/QUICK_START.md** - Step-by-step guide
4. **scripts/README.md** - Detailed documentation
5. **scripts/get_token_helper.dart** - Helper code snippets

## 🚀 How to Insert Hotels (2 Steps)

### Step 1: Get Your Access Token

I've already added a print statement to your `lib/services/auth_service.dart` file!

Just:
1. Run your Flutter app
2. Login with any account
3. Look in your console/terminal for:

```
═══════════════════════════════════════════════════════════════
🔑 ACCESS TOKEN FOR HOTEL INSERTION:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI...
═══════════════════════════════════════════════════════════════
```

4. Copy that long token

### Step 2: Run the Insertion Script

```bash
# Open scripts/insert_hotels.dart
# Replace 'YOUR_ACCESS_TOKEN' on line 12 with your copied token
# Then run:
dart run scripts/insert_hotels.dart
```

You'll see:
```
🏨 Inserting 15 dummy hotels into database...
✅ SUCCESS! Inserted 15 hotels
```

## 🏨 What You'll Get

### 15 Hotels Across All Categories:

**Luxury (3 hotels)** - ₹15,000-25,000/night
- The Royal Romance Palace (Udaipur) - 4.9★
- Sunset Paradise Resort (Goa) - 4.8★
- Himalayan Heights Retreat (Manali) - 4.7★

**Boutique (3 hotels)** - ₹8,500-11,000/night
- Heritage Haveli Romance (Jaipur) - 4.6★
- Coastal Charm Boutique (Pondicherry) - 4.7★
- Wine Valley Romance Resort (Nashik) - 4.5★

**Mid-Range (3 hotels)** - ₹5,500-7,500/night
- Garden View Romantic Inn (Ooty) - 4.4★
- Lakeside Serenity Hotel (Nainital) - 4.5★
- City Lights Romance Hotel (Mumbai) - 4.3★

**Budget (2 hotels)** - ₹2,800-3,500/night
- Cozy Nest Budget Stay (Bangalore) - 4.2★
- Hillside Budget Retreat (Shimla) - 4.1★

**Unique/Specialty (4 hotels)** - ₹10,000-14,000/night
- Treehouse Romance Escape (Wayanad) - 4.8★
- Desert Dunes Romantic Camp (Jaisalmer) - 4.6★
- Houseboat Honeymoon Haven (Alleppey) - 4.9★
- Colonial Charm Heritage Hotel (Darjeeling) - 4.6★

### Each Hotel Includes:

✅ Complete name and description (romantic, detailed)
✅ Real Indian locations with full addresses
✅ GPS coordinates (lat/lng)
✅ Star rating (2-5 stars)
✅ Couple rating (4.1-4.9)
✅ Price per night
✅ Privacy assured flag
✅ Category tag
✅ Comprehensive amenities (JSON object with 10-15 amenities each)
✅ 3 high-quality images (Unsplash URLs)
✅ Active status

## 🔍 Verify It Worked

1. Restart your Flutter app
2. Go to the home screen
3. You should see all 15 hotels displayed!
4. Try searching by city (Goa, Udaipur, etc.)
5. Check different price ranges

## 🧹 Cleanup (After Insertion)

Remove the token print statement from `lib/services/auth_service.dart`:

```dart
// Delete these lines (around line 120):
print('═══════════════════════════════════════════════════════════════');
print('🔑 ACCESS TOKEN FOR HOTEL INSERTION:');
print(_accessToken);
print('═══════════════════════════════════════════════════════════════');
print('Copy this token and use it in scripts/insert_hotels.dart');
print('Then remove this print statement from auth_service.dart');
print('═══════════════════════════════════════════════════════════════');
```

## 🎨 Hotel Features Highlights

- **Diverse Locations**: From beaches (Goa, Pondicherry) to mountains (Manali, Shimla) to heritage cities (Jaipur, Udaipur)
- **Romantic Amenities**: Couples massage, private dining, jacuzzi, champagne welcome, sunset cruises
- **Unique Experiences**: Treehouse stays, houseboat cruises, desert camping, wine tasting
- **Complete Data**: Every field populated with realistic, romantic descriptions
- **High Quality Images**: Professional Unsplash photos

## ⚡ Alternative: Quick curl Command

If you prefer using curl:

```bash
curl -X POST https://nukpc39r.ap-southeast.insforge.app/api/database/records/hotels \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d @scripts/hotels_data.json
```

## 📚 Need Help?

- Check `scripts/QUICK_START.md` for fastest method
- Check `scripts/README.md` for detailed instructions
- Check `scripts/get_token_helper.dart` for alternative token methods

## 🎉 That's It!

Your app will have 15 beautiful, fully-detailed romantic hotels ready for testing. Later you can replace them with real hotel data using the same structure!
