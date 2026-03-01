import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';
const String accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmNDJhOTJjYi1jY2FhLTQ2MTYtYmQxNC02OTM2YTkyNmE1ZGUiLCJlbWFpbCI6Im5pbGltZXNocGFsMjJAZ21haWwuY29tIiwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJpYXQiOjE3NzIyMjQxNTIsImV4cCI6MTc3MjIyNTA1Mn0.bnrlfX_skQU1KTZO35nu4npTEpIVjdM5RMnRASDzbC4';

void main() async {
  print('🏨 Inserting 20 hotels into database...\n');
  
  final hotels = [
    {
      'name': 'The Royal Romance Palace',
      'location': 'Udaipur, Rajasthan',
      'description': 'Experience ultimate luxury in our palatial suites with private pools, butler service, and breathtaking mountain views. Perfect for couples seeking an unforgettable romantic escape.',
      'rating': 4.9,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Spa', 'Restaurant', 'Bar', 'Gym', 'Butler Service', 'Jacuzzi'],
      'image_urls': ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.8,
      'safety_verified': true
    },
    {
      'name': 'Sunset Paradise Resort',
      'location': 'Goa',
      'description': 'Beachfront luxury resort offering private villas with infinity pools, couples spa treatments, and romantic candlelit dinners on the beach.',
      'rating': 4.8,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Spa', 'Restaurant', 'Beach Access', 'Water Sports', 'Jacuzzi'],
      'image_urls': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.5,
      'safety_verified': true
    },
    {
      'name': 'Himalayan Heights Retreat',
      'location': 'Manali, Himachal Pradesh',
      'description': 'Secluded mountain resort with panoramic Himalayan views, cozy fireplaces, and private balconies. Enjoy couples yoga and stargazing sessions.',
      'rating': 4.7,
      'amenities': ['Free Wifi', 'Spa', 'Restaurant', 'Fireplace', 'Mountain View', 'Yoga Sessions'],
      'image_urls': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.6,
      'safety_verified': true
    },
    {
      'name': 'Heritage Haveli Romance',
      'location': 'Jaipur, Rajasthan',
      'description': 'Charming heritage property with traditional architecture, antique furnishings, and modern comforts. Experience royal hospitality with rooftop dining.',
      'rating': 4.6,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Restaurant', 'Rooftop Dining', 'Cultural Shows', 'Heritage Tours'],
      'image_urls': ['https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.2,
      'safety_verified': true
    },
    {
      'name': 'Coastal Charm Boutique',
      'location': 'Pondicherry',
      'description': 'Intimate beachside boutique hotel with just 12 rooms. Enjoy personalized attention, private beach access, and romantic sunset cruises.',
      'rating': 4.7,
      'amenities': ['Free Wifi', 'Restaurant', 'Beach Access', 'Sunset Cruise', 'Bicycle Rental'],
      'image_urls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800', 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.4,
      'safety_verified': true
    },
    {
      'name': 'Garden View Romantic Inn',
      'location': 'Ooty, Tamil Nadu',
      'description': 'Peaceful garden hotel with spacious rooms, beautiful landscaping, and romantic gazebos. Complimentary breakfast and evening tea service.',
      'rating': 4.4,
      'amenities': ['Free Wifi', 'Restaurant', 'Garden', 'Complimentary Breakfast', 'Tea Service'],
      'image_urls': ['https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 8.8,
      'safety_verified': true
    },
    {
      'name': 'Lakeside Serenity Hotel',
      'location': 'Nainital, Uttarakhand',
      'description': 'Tranquil lakeside property offering rooms with lake views, boat rides, and peaceful surroundings. Perfect for nature walks and bird watching.',
      'rating': 4.5,
      'amenities': ['Free Wifi', 'Restaurant', 'Lake View', 'Boat Rides', 'Nature Walks'],
      'image_urls': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.0,
      'safety_verified': true
    },
    {
      'name': 'City Lights Romance Hotel',
      'location': 'Mumbai, Maharashtra',
      'description': 'Modern urban hotel in the heart of the city with rooftop restaurant and city views. Easy access to shopping and entertainment.',
      'rating': 4.3,
      'amenities': ['Free Wifi', 'Restaurant', 'Bar', 'Gym', 'Rooftop Dining', 'City View'],
      'image_urls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 8.5,
      'safety_verified': true
    },
    {
      'name': 'Cozy Nest Budget Stay',
      'location': 'Bangalore, Karnataka',
      'description': 'Clean, comfortable, and affordable accommodation perfect for young couples. Features cozy rooms, friendly staff, and all essential amenities.',
      'rating': 4.2,
      'amenities': ['Free Wifi', 'Restaurant', 'Parking', 'Complimentary Breakfast', 'Laundry'],
      'image_urls': ['https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 8.2,
      'safety_verified': true
    },
    {
      'name': 'Hillside Budget Retreat',
      'location': 'Shimla, Himachal Pradesh',
      'description': 'Affordable hillside property with stunning valley views and warm hospitality. Perfect for budget-conscious couples seeking a mountain escape.',
      'rating': 4.1,
      'amenities': ['Free Wifi', 'Restaurant', 'Mountain View', 'Complimentary Breakfast', 'Bonfire'],
      'image_urls': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 8.0,
      'safety_verified': true
    },
    {
      'name': 'Treehouse Romance Escape',
      'location': 'Wayanad, Kerala',
      'description': 'Unique treehouse accommodations nestled in lush forest canopy. Experience nature with luxury amenities, private decks, and bird watching.',
      'rating': 4.8,
      'amenities': ['Free Wifi', 'Restaurant', 'Nature Walks', 'Bird Watching', 'Private Deck', 'Jungle Safari'],
      'image_urls': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.7,
      'safety_verified': true
    },
    {
      'name': 'Desert Dunes Romantic Camp',
      'location': 'Jaisalmer, Rajasthan',
      'description': 'Luxury desert camping with air-conditioned tents, traditional Rajasthani hospitality, camel safaris, and cultural performances under the stars.',
      'rating': 4.6,
      'amenities': ['Restaurant', 'Camel Safari', 'Cultural Shows', 'Bonfire', 'Stargazing', 'Desert View'],
      'image_urls': ['https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.3,
      'safety_verified': true
    },
    {
      'name': 'Houseboat Honeymoon Haven',
      'location': 'Alleppey, Kerala',
      'description': 'Traditional Kerala houseboat with modern amenities, private chef, and serene backwater cruises. Float through palm-fringed canals.',
      'rating': 4.9,
      'amenities': ['Private Chef', 'Backwater Cruise', 'Fishing', 'Sunset Viewing', 'Traditional Meals'],
      'image_urls': ['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.9,
      'safety_verified': true
    },
    {
      'name': 'Wine Valley Romance Resort',
      'location': 'Nashik, Maharashtra',
      'description': 'Boutique resort in wine country offering vineyard tours, wine tasting sessions, gourmet dining, and rooms with valley views.',
      'rating': 4.5,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Restaurant', 'Wine Tasting', 'Vineyard Tours', 'Gourmet Dining'],
      'image_urls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800', 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.1,
      'safety_verified': true
    },
    {
      'name': 'Colonial Charm Heritage Hotel',
      'location': 'Darjeeling, West Bengal',
      'description': 'Restored colonial-era mansion with period furniture, manicured gardens, and old-world charm. Experience history with modern comforts.',
      'rating': 4.6,
      'amenities': ['Free Wifi', 'Restaurant', 'Garden', 'High Tea', 'Mountain View', 'Fireplace', 'Library'],
      'image_urls': ['https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.2,
      'safety_verified': true
    },
    {
      'name': 'Azure Waves Luxury Resort',
      'location': 'Andaman Islands',
      'description': 'Exclusive beachfront resort with overwater bungalows, private infinity pools, and world-class spa. Enjoy water sports and gourmet seafood dining.',
      'rating': 4.9,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Spa', 'Restaurant', 'Beach Access', 'Water Sports', 'Scuba Diving', 'Jacuzzi'],
      'image_urls': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.8,
      'safety_verified': true
    },
    {
      'name': 'Misty Mountains Eco Resort',
      'location': 'Coorg, Karnataka',
      'description': 'Sustainable luxury resort in pristine mountains. Solar-powered cottages, organic farm-to-table dining, nature trails, and meditation sessions.',
      'rating': 4.7,
      'amenities': ['Free Wifi', 'Restaurant', 'Mountain View', 'Nature Walks', 'Organic Food', 'Meditation', 'Yoga', 'Bonfire'],
      'image_urls': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.5,
      'safety_verified': true
    },
    {
      'name': 'Metropolitan Romance Suites',
      'location': 'Delhi',
      'description': 'Chic urban boutique hotel with designer interiors, rooftop infinity pool, and fine dining restaurant. Located in the heart of the city.',
      'rating': 4.5,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Spa', 'Restaurant', 'Bar', 'Gym', 'Rooftop Dining', 'City View', 'Valet Parking'],
      'image_urls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 8.7,
      'safety_verified': true
    },
    {
      'name': 'Riverside Serenity Lodge',
      'location': 'Rishikesh, Uttarakhand',
      'description': 'Peaceful riverside property with cottages overlooking flowing waters. Enjoy river rafting, fishing, campfires, and starlit dinners by the river.',
      'rating': 4.6,
      'amenities': ['Free Wifi', 'Restaurant', 'River View', 'River Rafting', 'Fishing', 'Bonfire', 'Yoga', 'Nature Walks'],
      'image_urls': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.3,
      'safety_verified': true
    },
    {
      'name': 'Royal Palace Heritage Stay',
      'location': 'Jodhpur, Rajasthan',
      'description': 'Converted royal palace offering regal suites with antique furniture and marble bathrooms. Experience maharaja lifestyle with elephant rides.',
      'rating': 4.8,
      'amenities': ['Free Wifi', 'Swimming Pool', 'Spa', 'Restaurant', 'Heritage Tours', 'Cultural Shows', 'Elephant Rides', 'Royal Dining', 'Butler Service'],
      'image_urls': ['https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'],
      'is_active': true,
      'couple_friendly': true,
      'local_id_allowed': true,
      'privacy_score': 9.6,
      'safety_verified': true
    },
  ];

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/database/records/hotels'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: jsonEncode(hotels),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SUCCESS! Inserted ${hotels.length} hotels');
      print('\nHotels added:');
      for (var hotel in hotels) {
        print('  • ${hotel['name']} (${hotel['location']}) - ${hotel['rating']}⭐');
      }
      print('\n🎉 All 20 hotels have been added to your database!');
      print('Restart your app to see them on the home screen.');
    } else {
      print('❌ FAILED');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
