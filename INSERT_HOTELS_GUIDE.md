# 🏨 How to Insert 20 Hotels into Your Database

## Current Status
You have 15 hotels defined in `scripts/insert_hotels.dart` but they haven't been inserted yet because the access token is set to `'YOUR_ACCESS_TOKEN'`.

## Quick Steps to Insert Hotels

### Step 1: Get Your Access Token

1. **Run your Flutter app:**
   ```bash
   flutter run
   ```

2. **Login to the app** with your account

3. **Check the console output** - Your auth service prints the access token:
   ```
   ═══════════════════════════════════════════════════════════════
   🔑 ACCESS TOKEN FOR HOTEL INSERTION:
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ═══════════════════════════════════════════════════════════════
   ```

4. **Copy the entire token** (it's a long string starting with `eyJ`)

### Step 2: Update the Script

1. Open `scripts/insert_hotels.dart`
2. Find line 12: `const String accessToken = 'YOUR_ACCESS_TOKEN';`
3. Replace with your actual token:
   ```dart
   const String accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Your actual token
   ```

### Step 3: Run the Script

```bash
dart run scripts/insert_hotels.dart
```

You should see:
```
🏨 Inserting 15 dummy hotels into database...
✅ SUCCESS! Inserted 15 hotels
```

## Want 20 Hotels Instead of 15?

I'll create 5 more hotels for you. Add these to the `hotels` list in the script:


### 5 Additional Hotels (16-20)

```dart
// Add these 5 hotels to your existing list:

// Hotel 16 - Luxury Beach Resort
{'name': 'Azure Waves Luxury Resort', 'description': 'Exclusive beachfront resort with overwater bungalows, private infinity pools, and world-class spa. Enjoy water sports, sunset yoga, and gourmet seafood dining. Ultimate luxury for discerning couples.', 'city': 'Andaman Islands', 'address': 'Havelock Island, Port Blair, Andaman and Nicobar 744211', 'lat': 11.9934, 'lng': 92.9718, 'star_rating': 5, 'couple_rating': 4.9, 'price_per_night': 28000, 'privacy_assured': true, 'category': 'luxury', 'amenities': {'wifi': true, 'pool': true, 'spa': true, 'restaurant': true, 'bar': true, 'gym': true, 'room_service': true, 'parking': true, 'beach_access': true, 'water_sports': true, 'couples_massage': true, 'private_dining': true, 'jacuzzi': true, 'overwater_bungalow': true, 'scuba_diving': true}, 'images': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800'], 'is_active': true},

// Hotel 17 - Mountain Eco Resort
{'name': 'Misty Mountains Eco Resort', 'description': 'Sustainable luxury resort in pristine mountains. Solar-powered cottages, organic farm-to-table dining, nature trails, and meditation sessions. Perfect for eco-conscious couples seeking tranquility.', 'city': 'Coorg', 'address': 'Madikeri Road, Coorg, Karnataka 571201', 'lat': 12.4244, 'lng': 75.7382, 'star_rating': 4, 'couple_rating': 4.7, 'price_per_night': 10500, 'privacy_assured': true, 'category': 'boutique', 'amenities': {'wifi': true, 'restaurant': true, 'room_service': true, 'parking': true, 'mountain_view': true, 'nature_walks': true, 'organic_food': true, 'meditation': true, 'yoga_sessions': true, 'bonfire': true, 'bird_watching': true, 'coffee_plantation_tour': true}, 'images': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'], 'is_active': true},

// Hotel 18 - Urban Boutique Hotel
{'name': 'Metropolitan Romance Suites', 'description': 'Chic urban boutique hotel with designer interiors, rooftop infinity pool, and Michelin-star restaurant. Located in the heart of the city with stunning skyline views. Modern luxury meets convenience.', 'city': 'Delhi', 'address': 'Connaught Place, New Delhi, Delhi 110001', 'lat': 28.6315, 'lng': 77.2167, 'star_rating': 5, 'couple_rating': 4.5, 'price_per_night': 16000, 'privacy_assured': true, 'category': 'luxury', 'amenities': {'wifi': true, 'pool': true, 'spa': true, 'restaurant': true, 'bar': true, 'gym': true, 'room_service': true, 'parking': true, 'rooftop_dining': true, 'city_view': true, 'concierge': true, 'valet_parking': true, 'business_center': true}, 'images': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800'], 'is_active': true},

// Hotel 19 - Riverside Retreat
{'name': 'Riverside Serenity Lodge', 'description': 'Peaceful riverside property with cottages overlooking flowing waters. Enjoy river rafting, fishing, campfires, and starlit dinners by the river. Perfect for adventure-loving couples.', 'city': 'Rishikesh', 'address': 'Neelkanth Road, Rishikesh, Uttarakhand 249304', 'lat': 30.0869, 'lng': 78.2676, 'star_rating': 3, 'couple_rating': 4.6, 'price_per_night': 7000, 'privacy_assured': true, 'category': 'mid-range', 'amenities': {'wifi': true, 'restaurant': true, 'room_service': true, 'parking': true, 'river_view': true, 'river_rafting': true, 'fishing': true, 'bonfire': true, 'yoga_sessions': true, 'nature_walks': true, 'complimentary_breakfast': true, 'adventure_sports': true}, 'images': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800'], 'is_active': true},

// Hotel 20 - Palace Heritage Hotel
{'name': 'Royal Palace Heritage Stay', 'description': 'Converted royal palace offering regal suites with antique furniture, marble bathrooms, and royal treatment. Experience maharaja lifestyle with elephant rides, folk performances, and royal dining.', 'city': 'Jodhpur', 'address': 'Mehrangarh Fort Road, Jodhpur, Rajasthan 342006', 'lat': 26.2967, 'lng': 73.0183, 'star_rating': 5, 'couple_rating': 4.8, 'price_per_night': 22000, 'privacy_assured': true, 'category': 'heritage', 'amenities': {'wifi': true, 'pool': true, 'spa': true, 'restaurant': true, 'bar': true, 'room_service': true, 'parking': true, 'heritage_tours': true, 'cultural_shows': true, 'elephant_rides': true, 'royal_dining': true, 'museum': true, 'palace_view': true, 'butler_service': true}, 'images': ['https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'], 'is_active': true},
```

## Complete Script with 20 Hotels

Here's the complete updated script. Save this as `scripts/insert_20_hotels.dart`:

