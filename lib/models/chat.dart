class ChatConversation {
  final String id;
  final String userId;
  final String? hotelId;
  final String? bookingId;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  ChatMessage? lastMessage;

  ChatConversation({
    required this.id,
    required this.userId,
    this.hotelId,
    this.bookingId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      hotelId: json['hotel_id'],
      bookingId: json['booking_id'],
      type: json['type'] ?? 'hotel',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType;
  final String message;
  final List<String>? attachments;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.attachments,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderType: json['sender_type'] ?? 'user',
      message: json['message'] ?? '',
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType,
      'message': message,
      'attachments': attachments,
      'is_read': isRead,
    };
  }

  bool get isFromUser => senderType == 'user';
  bool get isFromBot => senderType == 'bot';
}
