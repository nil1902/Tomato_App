import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class DatabaseService {
  final String _accessToken;

  DatabaseService(this._accessToken);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  Future<List<dynamic>> getHotels() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?order=rating.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Get Hotels Error: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getHotelDetails(String hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?id=eq.$hotelId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
      }
      return null;
    } catch (e) {
       print('Get Hotel Details Error: $e');
       return null;
    }
  }

  Future<List<dynamic>> getRooms(String hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/rooms?hotel_id=eq.$hotelId&order=price.asc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Get Rooms Error: $e');
      return [];
    }
  }

  Future<bool> createBooking({
    required String userId,
    required String hotelId,
    required String roomId,
    required String checkIn,
    required String checkOut,
    required int totalNights,
    required double totalAmount,
    Map<String, dynamic>? addons,
    String? occasion,
    String? specialRequests,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode([
          {
            'user_id': userId,
            'hotel_id': hotelId,
            'room_id': roomId,
            'checkin_date': checkIn,
            'checkout_date': checkOut,
            'total_nights': totalNights,
            'total_amount': totalAmount,
            'addons': addons,
            'status': 'confirmed',
            'occasion': occasion,
            'special_requests': specialRequests,
          }
        ]),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Create Booking Error: $e');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode({
          'status': 'cancelled',
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Cancel Booking Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
      }
      return null;
    } catch (e) {
      print('Get Booking Details Error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?user_id=eq.$userId&order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Get User Bookings Error: $e');
      return [];
    }
  }

  Future<bool> addToWishlist(String userId, String hotelId, {String? collectionName}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/wishlists'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode([
          {
            'user_id': userId,
            'hotel_id': hotelId,
            'collection_name': collectionName,
          }
        ]),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Add to Wishlist Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getUserWishlist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/wishlists?user_id=eq.$userId&order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Get User Wishlist Error: $e');
      return [];
    }
  }

  Future<bool> removeFromWishlist(String wishlistId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/wishlists?id=eq.$wishlistId'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Remove from Wishlist Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> searchHotels({
    String? query,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minRating,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}/api/database/records/hotels?is_active=eq.true';
      
      if (query != null && query.isNotEmpty) {
        url += '&name=ilike.%25${Uri.encodeComponent(query)}%25';
      }
      
      if (city != null && city.isNotEmpty) {
        url += '&city=ilike.%25${Uri.encodeComponent(city)}%25';
      }
      
      if (minPrice != null) {
        url += '&price_per_night=gte.$minPrice';
      }
      
      if (maxPrice != null) {
        url += '&price_per_night=lte.$maxPrice';
      }
      
      if (minRating != null) {
        url += '&couple_rating=gte.$minRating';
      }
      
      url += '&order=couple_rating.desc';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Search Hotels Error: $e');
      return [];
    }
  }

  Future<bool> createReview({
    required String hotelId,
    required String bookingId,
    required String userId,
    required int overallRating,
    required int cleanlinessRating,
    required int romanceRating,
    required int privacyRating,
    required int valueRating,
    required String comment,
    String? occasion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/reviews'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode([
          {
            'hotel_id': hotelId,
            'booking_id': bookingId,
            'user_id': userId,
            'overall_rating': overallRating,
            'cleanliness_rating': cleanlinessRating,
            'romance_rating': romanceRating,
            'privacy_rating': privacyRating,
            'value_rating': valueRating,
            'comment': comment,
            'occasion': occasion,
            'verified_stay': true,
          }
        ]),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Create Review Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getHotelReviews(String hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/reviews?hotel_id=eq.$hotelId&order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Get Hotel Reviews Error: $e');
      return [];
    }
  }
}
