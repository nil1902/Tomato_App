import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'api_constants.dart';

class NotificationService {
  // Fetch user notifications
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications?user_id=eq.$userId&order=created_at.desc'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AppNotification.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Table doesn't exist yet - return empty list gracefully
        print('⚠️ Notifications table not found. Please create it in your database.');
        return [];
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications?user_id=eq.$userId&is_read=eq.false&select=count'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      } else if (response.statusCode == 404) {
        // Table doesn't exist yet - return 0 gracefully
        return 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/notifications?id=eq.$notificationId'),
        headers: ApiConstants.headers,
        body: json.encode({'is_read': true}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/notifications?user_id=eq.$userId&is_read=eq.false'),
        headers: ApiConstants.headers,
        body: json.encode({'is_read': true}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  // Create a notification (for testing or admin use)
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications'),
        headers: ApiConstants.headers,
        body: json.encode({
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type,
          'data': data,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/notifications?id=eq.$notificationId'),
        headers: ApiConstants.headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}
