class Addon {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final bool isActive;
  bool isSelected;

  Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    this.isActive = true,
    this.isSelected = false,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  String get categoryIcon {
    switch (category) {
      case 'decoration':
        return '🎀';
      case 'food':
        return '🍽️';
      case 'experience':
        return '✨';
      case 'gift':
        return '🎁';
      default:
        return '💝';
    }
  }
}
