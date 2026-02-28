class Review {
  final String id;
  final String hotelId;
  final String bookingId;
  final String userId;
  final int overallRating;
  final int cleanlinessRating;
  final int romanceRating;
  final int privacyRating;
  final int valueRating;
  final String comment;
  final List<String> images;
  final String? occasion;
  final bool verifiedStay;
  final DateTime createdAt;

  // Additional fields for display
  String? userName;
  String? userAvatar;

  Review({
    required this.id,
    required this.hotelId,
    required this.bookingId,
    required this.userId,
    required this.overallRating,
    required this.cleanlinessRating,
    required this.romanceRating,
    required this.privacyRating,
    required this.valueRating,
    required this.comment,
    required this.images,
    this.occasion,
    required this.verifiedStay,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      userId: json['user_id'] ?? '',
      overallRating: json['overall_rating'] ?? 0,
      cleanlinessRating: json['cleanliness_rating'] ?? 0,
      romanceRating: json['romance_rating'] ?? 0,
      privacyRating: json['privacy_rating'] ?? 0,
      valueRating: json['value_rating'] ?? 0,
      comment: json['comment'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      occasion: json['occasion'],
      verifiedStay: json['verified_stay'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'booking_id': bookingId,
      'user_id': userId,
      'overall_rating': overallRating,
      'cleanliness_rating': cleanlinessRating,
      'romance_rating': romanceRating,
      'privacy_rating': privacyRating,
      'value_rating': valueRating,
      'comment': comment,
      'images': images,
      'occasion': occasion,
      'verified_stay': verifiedStay,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
