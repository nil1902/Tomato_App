import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

class UserProfileService {
  final String _accessToken;

  UserProfileService(this._accessToken);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  /// Get user profile by user_id
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?user_id=eq.$userId'),
        headers: _headers,
      );
      
      debugPrint('📱 Get Profile Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0];
        }
      }
      return null;
    } catch (e) {
      debugPrint('📱 Get Profile Error: $e');
      return null;
    }
  }

  /// Get user profile by email
  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?email=eq.$email'),
        headers: _headers,
      );
      
      debugPrint('📱 Get Profile by Email Response: ${response.statusCode}');
      debugPrint('📱 Response body: ${response.body}');
      debugPrint('📱 Response length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        debugPrint('📱 About to decode profile response...');
        final data = jsonDecode(response.body);
        debugPrint('📱 Profile decode successful!');
        if (data is List && data.isNotEmpty) {
          return data[0];
        }
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('📱 Get Profile by Email Error: $e');
      debugPrint('📱 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Create a new user profile
  Future<bool> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? partnerName,
    String? anniversaryDate,
    String? avatarUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode([
          {
            'user_id': userId,
            'name': name,
            'email': email,
            'phone': phone,
            'partner_name': partnerName,
            'anniversary_date': anniversaryDate,
            'avatar_url': avatarUrl,
          }
        ]),
      );
      
      debugPrint('📱 Create Profile Response: ${response.statusCode}');
      debugPrint('📱 Create Profile Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('📱 Create Profile Error: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? partnerName,
    String? anniversaryDate,
    String? avatarUrl,
  }) async {
    try {
      // Build the update object with only non-null values
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (partnerName != null) updateData['partner_name'] = partnerName;
      if (anniversaryDate != null) updateData['anniversary_date'] = anniversaryDate;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?user_id=eq.$userId'),
        headers: {
          ..._headers,
          'Prefer': 'return=representation'
        },
        body: jsonEncode(updateData),
      );
      
      debugPrint('📱 Update Profile Response: ${response.statusCode}');
      debugPrint('📱 Update Profile Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('📱 Update Profile Error: $e');
      return false;
    }
  }

  /// Delete user profile
  Future<bool> deleteUserProfile(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/database/records/user_profiles?user_id=eq.$userId'),
        headers: _headers,
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('📱 Delete Profile Error: $e');
      return false;
    }
  }
}
