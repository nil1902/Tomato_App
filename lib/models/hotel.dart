class Hotel {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final double? lat;
  final double? lng;
  final int starRating;
  final double coupleRating;
  final Map<String, dynamic>? amenities;
  final List<String> images;
  final double basePrice;
  final bool isActive;
  final DateTime createdAt;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    this.lat,
    this.lng,
    required this.starRating,
    required this.coupleRating,
    this.amenities,
    required this.images,
    required this.basePrice,
    required this.isActive,
    required this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      starRating: json['star_rating'] ?? 0,
      coupleRating: (json['couple_rating'] ?? 0).toDouble(),
      amenities: json['amenities'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      basePrice: (json['base_price'] ?? json['price_per_night'] ?? json['starting_price'] ?? 200).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'lat': lat,
      'lng': lng,
      'star_rating': starRating,
      'couple_rating': coupleRating,
      'amenities': amenities,
      'images': images,
      'base_price': basePrice,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
