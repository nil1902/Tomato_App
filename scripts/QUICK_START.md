# 🚀 QUICK START - Insert Hotels in 2 Minutes

## Fastest Method (Copy-Paste Ready)

### Step 1: Get Your Token

Run your Flutter app and login. Then add this ONE line temporarily:

**In `lib/services/auth_service.dart`** - Find the `login` method and add after line where `_accessToken` is set:

```dart
print('TOKEN: $_accessToken');
```

### Step 2: Copy the Token

Look in your console/terminal for:
```
TOKEN: eyJhbGc...your-long-token-here...
```

### Step 3: Run the Script

```bash
# Replace YOUR_ACCESS_TOKEN with the token you copied
dart run scripts/insert_hotels.dart
```

That's it! You'll see:
```
✅ SUCCESS! Inserted 15 hotels
```

---

## Even Faster: Direct curl Command

If you have curl installed:

```bash
# Replace YOUR_TOKEN_HERE with your actual token
curl -X POST https://nukpc39r.ap-southeast.insforge.app/api/database/records/hotels \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d @scripts/hotels_data.json
```

---

## What You'll Get

15 hotels instantly:
- ✅ All categories (luxury, boutique, mid-range, budget, unique)
- ✅ Full details (descriptions, amenities, images)
- ✅ Real Indian locations (Udaipur, Goa, Manali, etc.)
- ✅ Proper pricing (₹2,800 to ₹25,000/night)
- ✅ High ratings (4.1 to 4.9)

## Verify It Worked

1. Restart your Flutter app
2. Go to home screen
3. You should see all 15 hotels!

---

## Troubleshooting

**Can't find token?**
- Make sure you're logged in
- Check the console output after login
- Token starts with "eyJ"

**Script fails?**
- Check internet connection
- Verify token is not expired (login again)
- Make sure you replaced YOUR_ACCESS_TOKEN in the script

**Need help?**
- Check `scripts/README.md` for detailed instructions
- Check `scripts/get_token_helper.dart` for more ways to get token
