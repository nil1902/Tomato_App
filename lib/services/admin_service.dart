import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

class AdminService {
  String? _accessToken;

  AdminService([this._accessToken]);

  Map<String, String> get _headers => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  // ==================== HOTEL MANAGEMENT ====================
  
  Future<List<dynamic>> getAllHotels() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Hotels Error: $e');
      return [];
    }
  }

  Future<bool> addHotel(Map<String, dynamic> hotelData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode([hotelData]),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Admin Create Hotel Error: $e');
      return false;
    }
  }

  Future<bool> updateHotel(String hotelId, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?id=eq.$hotelId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode(updates),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Update Hotel Error: $e');
      return false;
    }
  }

  Future<bool> deleteHotel(String hotelId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?id=eq.$hotelId'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Delete Hotel Error: $e');
      return false;
    }
  }

  // ==================== BOOKING MANAGEMENT ====================
  
  Future<List<dynamic>> getAllBookings({String? status}) async {
    try {
      String url = '${ApiConstants.baseUrl}/api/database/records/bookings?order=created_at.desc';
      if (status != null) {
        url += '&status=eq.$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Bookings Error: $e');
      return [];
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Update Booking Error: $e');
      return false;
    }
  }

  Future<bool> deleteBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Delete Booking Error: $e');
      return false;
    }
  }

  // ==================== USER MANAGEMENT ====================
  
  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Users Error: $e');
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?user_id=eq.$userId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({'role': role}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Update User Role Error: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?user_id=eq.$userId'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Delete User Error: $e');
      return false;
    }
  }

  // ==================== ANALYTICS ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total hotels
      final hotelsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?select=count'),
        headers: _headers,
      );
      
      // Get total bookings
      final bookingsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?select=count'),
        headers: _headers,
      );
      
      // Get total users
      final usersResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?select=count'),
        headers: _headers,
      );
      
      // Get today's bookings
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayBookingsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?created_at=gte.$today&select=count'),
        headers: _headers,
      );
      
      return {
        'total_hotels': hotelsResponse.statusCode == 200 ? (jsonDecode(hotelsResponse.body) as List).length : 0,
        'total_bookings': bookingsResponse.statusCode == 200 ? (jsonDecode(bookingsResponse.body) as List).length : 0,
        'total_users': usersResponse.statusCode == 200 ? (jsonDecode(usersResponse.body) as List).length : 0,
        'today_bookings': todayBookingsResponse.statusCode == 200 ? (jsonDecode(todayBookingsResponse.body) as List).length : 0,
      };
    } catch (e) {
      debugPrint('Admin Get Stats Error: $e');
      return {
        'total_hotels': 0,
        'total_bookings': 0,
        'total_users': 0,
        'today_bookings': 0,
      };
    }
  }

  // ==================== REVIEWS MANAGEMENT ====================
  
  Future<List<dynamic>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/reviews?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Reviews Error: $e');
      return [];
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/reviews?id=eq.$reviewId'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Admin Delete Review Error: $e');
      return false;
    }
  }

  // ==================== BANNERS MANAGEMENT ====================
  
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/banners?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Banners Error: $e');
      return [];
    }
  }

  Future<void> addBanner(Map<String, dynamic> bannerData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/banners'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode([bannerData]),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add banner');
      }
    } catch (e) {
      debugPrint('Admin Add Banner Error: $e');
      rethrow;
    }
  }

  Future<void> updateBannerStatus(String bannerId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/banners?id=eq.$bannerId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({'is_active': isActive}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update banner status');
      }
    } catch (e) {
      debugPrint('Admin Update Banner Status Error: $e');
      rethrow;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/banners?id=eq.$bannerId'),
        headers: _headers,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete banner');
      }
    } catch (e) {
      debugPrint('Admin Delete Banner Error: $e');
      rethrow;
    }
  }

  // ==================== POPUPS MANAGEMENT ====================
  
  Future<List<Map<String, dynamic>>> getPopups() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/popups?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Popups Error: $e');
      return [];
    }
  }

  Future<void> addPopup(Map<String, dynamic> popupData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/popups'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode([popupData]),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add popup');
      }
    } catch (e) {
      debugPrint('Admin Add Popup Error: $e');
      rethrow;
    }
  }

  Future<void> updatePopupStatus(String popupId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/popups?id=eq.$popupId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({'is_active': isActive}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update popup status');
      }
    } catch (e) {
      debugPrint('Admin Update Popup Status Error: $e');
      rethrow;
    }
  }

  Future<void> deletePopup(String popupId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/popups?id=eq.$popupId'),
        headers: _headers,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete popup');
      }
    } catch (e) {
      debugPrint('Admin Delete Popup Error: $e');
      rethrow;
    }
  }

  // ==================== DISCOUNTS MANAGEMENT ====================
  
  Future<List<Map<String, dynamic>>> getDiscounts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/discounts?order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Admin Get Discounts Error: $e');
      return [];
    }
  }

  Future<void> addDiscount(Map<String, dynamic> discountData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/discounts'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode([discountData]),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add discount');
      }
    } catch (e) {
      debugPrint('Admin Add Discount Error: $e');
      rethrow;
    }
  }

  Future<void> updateDiscountStatus(String discountId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/discounts?id=eq.$discountId'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({'is_active': isActive}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update discount status');
      }
    } catch (e) {
      debugPrint('Admin Update Discount Status Error: $e');
      rethrow;
    }
  }

  Future<void> deleteDiscount(String discountId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/discounts?id=eq.$discountId'),
        headers: _headers,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete discount');
      }
    } catch (e) {
      debugPrint('Admin Delete Discount Error: $e');
      rethrow;
    }
  }
}
