# Hotel Data Insertion Scripts

## Quick Start - Insert 15 Dummy Hotels

### Method 1: Using Dart Script (Recommended)

1. **Get your access token:**
   - Open your Flutter app
   - Login with your account
   - The token is stored in `AuthService` after login

2. **Update the script:**
   ```bash
   # Open scripts/insert_hotels.dart
   # Replace 'YOUR_ACCESS_TOKEN' with your actual token
   ```

3. **Run the script:**
   ```bash
   dart run scripts/insert_hotels.dart
   ```

### Method 2: Using curl (Quick Alternative)

If you have your access token, you can use curl directly:

```bash
curl -X POST https://nukpc39r.ap-southeast.insforge.app/api/database/records/hotels \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d @scripts/hotels_data.json
```

### Method 3: Get Token from App

Add this temporary code to your app to print the token:

```dart
// In lib/services/auth_service.dart, after successful login:
print('🔑 Access Token: $_accessToken');
```

Then:
1. Run your app
2. Login
3. Copy the token from console
4. Use it in the script

## What Gets Inserted

15 hotels across all categories:
- **3 Luxury Hotels** (₹15,000-25,000/night)
  - The Royal Romance Palace (Udaipur)
  - Sunset Paradise Resort (Goa)
  - Himalayan Heights Retreat (Manali)

- **3 Boutique Hotels** (₹8,500-11,000/night)
  - Heritage Haveli Romance (Jaipur)
  - Coastal Charm Boutique (Pondicherry)
  - Wine Valley Romance Resort (Nashik)

- **3 Mid-Range Hotels** (₹5,500-7,500/night)
  - Garden View Romantic Inn (Ooty)
  - Lakeside Serenity Hotel (Nainital)
  - City Lights Romance Hotel (Mumbai)

- **2 Budget Hotels** (₹2,800-3,500/night)
  - Cozy Nest Budget Stay (Bangalore)
  - Hillside Budget Retreat (Shimla)

- **4 Unique/Specialty Hotels** (₹10,000-14,000/night)
  - Treehouse Romance Escape (Wayanad)
  - Desert Dunes Romantic Camp (Jaisalmer)
  - Houseboat Honeymoon Haven (Alleppey)
  - Colonial Charm Heritage Hotel (Darjeeling)

Each hotel includes:
- Complete details (name, description, address, coordinates)
- Star rating and couple rating
- Price per night
- Comprehensive amenities (JSON object)
- Multiple images (Unsplash URLs)
- Category and privacy assured flag

## Troubleshooting

**Error: 401 Unauthorized**
- Your access token is invalid or expired
- Login again and get a fresh token

**Error: 400 Bad Request**
- Check if the hotels table exists in your database
- Verify the schema matches the data structure

**Error: Network issues**
- Check your internet connection
- Verify the base URL is correct

## Files

- `insert_hotels.dart` - Main script with embedded data
- `hotels_data.json` - JSON file with all hotel data
- `insert_dummy_hotels.dart` - Alternative script (same functionality)
