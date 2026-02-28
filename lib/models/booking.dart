class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalNights;
  final Map<String, dynamic>? addons;
  final double totalAmount;
  final String status;
  final String? occasion;
  final String? specialRequests;
  final DateTime createdAt;

  // Additional fields for display
  String? hotelName;
  String? hotelLocation;
  String? hotelImage;
  String? roomType;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    this.addons,
    required this.totalAmount,
    required this.status,
    this.occasion,
    this.specialRequests,
    required this.createdAt,
    this.hotelName,
    this.hotelLocation,
    this.hotelImage,
    this.roomType,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      roomId: json['room_id'] ?? '',
      checkInDate: json['checkin_date'] != null 
          ? DateTime.parse(json['checkin_date']) 
          : DateTime.now(),
      checkOutDate: json['checkout_date'] != null 
          ? DateTime.parse(json['checkout_date']) 
          : DateTime.now(),
      totalNights: json['total_nights'] ?? 1,
      addons: json['addons'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      occasion: json['occasion'],
      specialRequests: json['special_requests'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      hotelName: json['hotel_name'],
      hotelLocation: json['hotel_location'],
      hotelImage: json['hotel_image'],
      roomType: json['room_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'checkin_date': checkInDate.toIso8601String().split('T')[0],
      'checkout_date': checkOutDate.toIso8601String().split('T')[0],
      'total_nights': totalNights,
      'addons': addons,
      'total_amount': totalAmount,
      'status': status,
      'occasion': occasion,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUpcoming => status == 'confirmed' && checkInDate.isAfter(DateTime.now());
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
