import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import 'api_constants.dart';

class ChatService {
  // Get or create conversation
  Future<ChatConversation?> getOrCreateConversation({
    required String userId,
    String? hotelId,
    String? bookingId,
    String type = 'hotel',
  }) async {
    try {
      // Check if conversation exists
      String url = '${ApiConstants.baseUrl}/chat_conversations?user_id=eq.$userId&type=eq.$type&status=eq.active';
      if (hotelId != null) {
        url += '&hotel_id=eq.$hotelId';
      }

      var response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return ChatConversation.fromJson(data[0]);
        }
      }

      // Create new conversation
      response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat_conversations'),
        headers: ApiConstants.headers,
        body: json.encode({
          'user_id': userId,
          'hotel_id': hotelId,
          'booking_id': bookingId,
          'type': type,
          'status': 'active',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatConversation.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      print('Error getting/creating conversation: $e');
      return null;
    }
  }

  // Get user conversations
  Future<List<ChatConversation>> getUserConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat_conversations?user_id=eq.$userId&order=updated_at.desc'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // Get messages for a conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat_messages?conversation_id=eq.$conversationId&order=created_at.asc'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // Send message
  Future<ChatMessage?> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    String senderType = 'user',
    List<String>? attachments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat_messages'),
        headers: ApiConstants.headers,
        body: json.encode({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'sender_type': senderType,
          'message': message,
          'attachments': attachments,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Update conversation timestamp
        await http.patch(
          Uri.parse('${ApiConstants.baseUrl}/chat_conversations?id=eq.$conversationId'),
          headers: ApiConstants.headers,
          body: json.encode({
            'updated_at': DateTime.now().toIso8601String(),
          }),
        );

        return ChatMessage.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/chat_messages?conversation_id=eq.$conversationId&sender_id=neq.$userId&is_read=eq.false'),
        headers: ApiConstants.headers,
        body: json.encode({'is_read': true}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(String userId) async {
    try {
      final conversations = await getUserConversations(userId);
      int totalUnread = 0;

      for (var conv in conversations) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/chat_messages?conversation_id=eq.${conv.id}&sender_id=neq.$userId&is_read=eq.false'),
          headers: ApiConstants.headers,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          totalUnread += data.length;
        }
      }

      return totalUnread;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Close conversation
  Future<bool> closeConversation(String conversationId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/chat_conversations?id=eq.$conversationId'),
        headers: ApiConstants.headers,
        body: json.encode({'status': 'closed'}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error closing conversation: $e');
      return false;
    }
  }

  // Auto-reply bot (improved implementation)
  Future<void> sendBotReply(String conversationId, String userMessage) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate thinking

    String botReply = _generateBotReply(userMessage);
    
    await sendMessage(
      conversationId: conversationId,
      senderId: 'bot',
      message: botReply,
      senderType: 'bot',
    );
  }

  String _generateBotReply(String userMessage) {
    final msg = userMessage.toLowerCase();
    
    // Greetings
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return '👋 Hello! Welcome to LoveNest! How can I help you today?\n\nI can assist with:\n• Bookings & reservations\n• Cancellations & refunds\n• Loyalty points\n• Special offers\n• Account settings';
    }
    
    // Booking related
    if (msg.contains('book') || msg.contains('reservation')) {
      return '📅 To make a booking:\n\n1. Browse our romantic hotels\n2. Select your dates\n3. Choose your room\n4. Add romantic extras (optional)\n5. Complete payment\n\nNeed help with a specific booking? Please share your booking ID or let me know what you need!';
    }
    
    // Cancellation
    if (msg.contains('cancel')) {
      return '❌ Cancellation Policy:\n\n• Free cancellation up to 24 hours before check-in\n• After 24 hours, fees may apply\n• Refunds processed within 5-7 business days\n\nTo cancel: Go to My Bookings → Select booking → Cancel\n\nNeed help? I can connect you with support.';
    }
    
    // Payment
    if (msg.contains('payment') || msg.contains('pay')) {
      return '💳 We accept:\n• Visa, Mastercard, Amex\n• Debit Cards\n• PayPal\n• Apple Pay & Google Pay\n\nAll payments are secure and encrypted. Having payment issues? Contact support@lovenest.com';
    }
    
    // Loyalty
    if (msg.contains('point') || msg.contains('loyalty') || msg.contains('reward')) {
      return '🎁 Loyalty Program:\n\n• Earn 1 point per \$1 spent\n• 100 points = \$1 discount\n• Bonus points for reviews\n• Referral rewards: 500 points\n\nCheck your points in the Loyalty section!';
    }
    
    // Add-ons
    if (msg.contains('addon') || msg.contains('add-on') || msg.contains('romantic') || msg.contains('rose')) {
      return '🌹 Romantic Add-ons:\n\n• Rose Petals & Candles\n• Champagne & Chocolates\n• Couples Spa Package\n• Gift Baskets\n• Live Music\n\nAdd them during booking or anytime before check-in!';
    }
    
    // Offers
    if (msg.contains('offer') || msg.contains('coupon') || msg.contains('discount')) {
      return '🏷️ Current Offers:\n\nCheck "Coupons & Offers" for active deals! We have:\n• First booking discounts\n• Seasonal promotions\n• Loyalty member exclusives\n\nCoupons are automatically applied at checkout!';
    }
    
    // Contact/Support
    if (msg.contains('contact') || msg.contains('support') || msg.contains('help')) {
      return '📞 Contact Us:\n\n📧 Email: support@lovenest.com\n📞 Phone: 1-800-LOVE-NEST (24/7)\n💬 Live Chat: Available now\n\nHow else can I help you?';
    }
    
    // Thanks
    if (msg.contains('thank')) {
      return '💕 You\'re very welcome! Is there anything else I can help you with? I\'m here to make your experience perfect!';
    }
    
    // Default
    return '🤖 I\'m here to help! I can assist with:\n\n📅 Bookings & reservations\n❌ Cancellations\n🎁 Loyalty points\n💳 Payments\n🌹 Romantic add-ons\n🏷️ Offers & coupons\n\nWhat would you like to know?';
  }
}
