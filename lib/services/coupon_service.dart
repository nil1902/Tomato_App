import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';
import 'api_constants.dart';

class CouponService {
  // Fetch all active coupons
  Future<List<Coupon>> getActiveCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/coupons?is_active=eq.true'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Coupon.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load coupons');
      }
    } catch (e) {
      print('Error fetching coupons: $e');
      return [];
    }
  }

  // Validate and get coupon by code
  Future<Coupon?> validateCoupon(String code, double bookingAmount) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/coupons?code=eq.$code&is_active=eq.true'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return null;

        final coupon = Coupon.fromJson(data[0]);
        
        // Validate coupon
        if (!coupon.isValid) return null;
        if (coupon.minBookingAmount != null && bookingAmount < coupon.minBookingAmount!) {
          return null;
        }

        return coupon;
      }
      return null;
    } catch (e) {
      print('Error validating coupon: $e');
      return null;
    }
  }

  // Apply coupon to booking
  Future<bool> applyCoupon({
    required String couponId,
    required String userId,
    required String bookingId,
    required double discountAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/coupon_usage'),
        headers: ApiConstants.headers,
        body: json.encode({
          'coupon_id': couponId,
          'user_id': userId,
          'booking_id': bookingId,
          'discount_amount': discountAmount,
        }),
      );

      if (response.statusCode == 201) {
        // Increment used count
        await http.patch(
          Uri.parse('${ApiConstants.baseUrl}/coupons?id=eq.$couponId'),
          headers: ApiConstants.headers,
          body: json.encode({
            'used_count': 'used_count + 1',
          }),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error applying coupon: $e');
      return false;
    }
  }

  // Check if user has used a coupon
  Future<bool> hasUserUsedCoupon(String userId, String couponId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/coupon_usage?user_id=eq.$userId&coupon_id=eq.$couponId'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking coupon usage: $e');
      return false;
    }
  }

  // Get user's coupon usage history
  Future<List<Map<String, dynamic>>> getUserCouponHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/coupon_usage?user_id=eq.$userId&order=used_at.desc'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching coupon history: $e');
      return [];
    }
  }
}
