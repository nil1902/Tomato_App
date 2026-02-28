class Room {
  final String id;
  final String hotelId;
  final String type;
  final String description;
  final double pricePerNight;
  final int maxOccupancy;
  final Map<String, dynamic>? amenities;
  final List<String> images;
  final bool isAvailable;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.maxOccupancy,
    this.amenities,
    required this.images,
    required this.isAvailable,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      maxOccupancy: json['max_occupancy'] ?? 2,
      amenities: json['amenities'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'type': type,
      'description': description,
      'price_per_night': pricePerNight,
      'max_occupancy': maxOccupancy,
      'amenities': amenities,
      'images': images,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
