import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import 'api_constants.dart';

class BookingService {
  final String _accessToken;

  BookingService(this._accessToken);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  Future<List<Booking>> getUserBookings(String userId, {String? status}) async {
    try {
      String url = '${ApiConstants.baseUrl}/api/database/records/bookings?user_id=eq.$userId';
      
      if (status != null) {
        url += '&status=eq.$status';
      }
      
      url += '&order=created_at.desc';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Booking> bookings = [];
        
        for (var bookingData in data) {
          final booking = Booking.fromJson(bookingData);
          
          // Fetch hotel details
          final hotelResponse = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?id=eq.${booking.hotelId}'),
            headers: _headers,
          );
          
          if (hotelResponse.statusCode == 200) {
            final hotelData = jsonDecode(hotelResponse.body);
            if (hotelData.isNotEmpty) {
              final hotel = Hotel.fromJson(hotelData[0]);
              booking.hotelName = hotel.name;
              booking.hotelLocation = '${hotel.city}, ${hotel.address}';
              booking.hotelImage = hotel.images.isNotEmpty ? hotel.images[0] : null;
            }
          }
          
          // Fetch room details
          final roomResponse = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/database/records/rooms?id=eq.${booking.roomId}'),
            headers: _headers,
          );
          
          if (roomResponse.statusCode == 200) {
            final roomData = jsonDecode(roomResponse.body);
            if (roomData.isNotEmpty) {
              final room = Room.fromJson(roomData[0]);
              booking.roomType = room.type;
            }
          }
          
          bookings.add(booking);
        }
        
        return bookings;
      }
      return [];
    } catch (e) {
      debugPrint('Get User Bookings Error: $e');
      return [];
    }
  }

  Future<Booking?> getBookingDetails(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final booking = Booking.fromJson(data[0]);
          
          // Fetch hotel details
          final hotelResponse = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/database/records/hotels?id=eq.${booking.hotelId}'),
            headers: _headers,
          );
          
          if (hotelResponse.statusCode == 200) {
            final hotelData = jsonDecode(hotelResponse.body);
            if (hotelData.isNotEmpty) {
              final hotel = Hotel.fromJson(hotelData[0]);
              booking.hotelName = hotel.name;
              booking.hotelLocation = '${hotel.city}, ${hotel.address}';
              booking.hotelImage = hotel.images.isNotEmpty ? hotel.images[0] : null;
            }
          }
          
          // Fetch room details
          final roomResponse = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/database/records/rooms?id=eq.${booking.roomId}'),
            headers: _headers,
          );
          
          if (roomResponse.statusCode == 200) {
            final roomData = jsonDecode(roomResponse.body);
            if (roomData.isNotEmpty) {
              final room = Room.fromJson(roomData[0]);
              booking.roomType = room.type;
            }
          }
          
          return booking;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get Booking Details Error: $e');
      return null;
    }
  }

  Future<bool> createBooking({
    required String userId,
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
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
            'checkin_date': checkInDate.toIso8601String().split('T')[0],
            'checkout_date': checkOutDate.toIso8601String().split('T')[0],
            'total_nights': totalNights,
            'total_amount': totalAmount,
            'addons': addons,
            'status': 'confirmed',
            'occasion': occasion,
            'special_requests': specialRequests,
          }
        ]),
      );
      
      debugPrint('Create Booking Response: ${response.statusCode}');
      debugPrint('Create Booking Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Create Booking Error: $e');
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
      debugPrint('Cancel Booking Error: $e');
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/bookings?id=eq.$bookingId'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode({
          'status': status,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Update Booking Status Error: $e');
      return false;
    }
  }
}
