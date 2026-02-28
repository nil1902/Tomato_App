import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loyalty_points.dart';
import 'api_constants.dart';

class LoyaltyService {
  // Get user's loyalty points
  Future<LoyaltyPoints?> getUserLoyaltyPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/loyalty_points?user_id=eq.$userId'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          // Create initial loyalty account
          return await createLoyaltyAccount(userId);
        }
        return LoyaltyPoints.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      print('Error fetching loyalty points: $e');
      return null;
    }
  }

  // Create loyalty account for new user
  Future<LoyaltyPoints?> createLoyaltyAccount(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/loyalty_points'),
        headers: ApiConstants.headers,
        body: json.encode({
          'user_id': userId,
          'points': 0,
          'lifetime_points': 0,
          'tier': 'bronze',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return LoyaltyPoints.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      print('Error creating loyalty account: $e');
      return null;
    }
  }

  // Add points to user account
  Future<bool> addPoints({
    required String userId,
    required int points,
    required String description,
    String? bookingId,
  }) async {
    try {
      // Create transaction
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/points_transactions'),
        headers: ApiConstants.headers,
        body: json.encode({
          'user_id': userId,
          'points': points,
          'transaction_type': 'earned',
          'description': description,
          'booking_id': bookingId,
        }),
      );

      // Update user points
      final loyalty = await getUserLoyaltyPoints(userId);
      if (loyalty != null) {
        final newPoints = loyalty.points + points;
        final newLifetimePoints = loyalty.lifetimePoints + points;
        final newTier = _calculateTier(newLifetimePoints);

        await http.patch(
          Uri.parse('${ApiConstants.baseUrl}/loyalty_points?user_id=eq.$userId'),
          headers: ApiConstants.headers,
          body: json.encode({
            'points': newPoints,
            'lifetime_points': newLifetimePoints,
            'tier': newTier,
            'updated_at': DateTime.now().toIso8601String(),
          }),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding points: $e');
      return false;
    }
  }

  // Redeem points
  Future<bool> redeemPoints({
    required String userId,
    required int points,
    required String description,
  }) async {
    try {
      final loyalty = await getUserLoyaltyPoints(userId);
      if (loyalty == null || loyalty.points < points) {
        return false;
      }

      // Create transaction
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/points_transactions'),
        headers: ApiConstants.headers,
        body: json.encode({
          'user_id': userId,
          'points': -points,
          'transaction_type': 'redeemed',
          'description': description,
        }),
      );

      // Update user points
      final newPoints = loyalty.points - points;
      await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/loyalty_points?user_id=eq.$userId'),
        headers: ApiConstants.headers,
        body: json.encode({
          'points': newPoints,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
      return true;
    } catch (e) {
      print('Error redeeming points: $e');
      return false;
    }
  }

  // Get points transaction history
  Future<List<PointsTransaction>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/points_transactions?user_id=eq.$userId&order=created_at.desc'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PointsTransaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transaction history: $e');
      return [];
    }
  }

  // Calculate tier based on lifetime points
  String _calculateTier(int lifetimePoints) {
    if (lifetimePoints >= 10000) return 'platinum';
    if (lifetimePoints >= 5000) return 'gold';
    if (lifetimePoints >= 1000) return 'silver';
    return 'bronze';
  }

  // Calculate points earned from booking
  int calculatePointsFromBooking(double bookingAmount) {
    // 1 point per dollar spent
    return bookingAmount.round();
  }

  // Convert points to discount value
  double pointsToDiscount(int points) {
    // 100 points = $1 discount
    return points / 100;
  }
}
