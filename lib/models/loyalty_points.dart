class LoyaltyPoints {
  final String id;
  final String userId;
  final int points;
  final int lifetimePoints;
  final String tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.points,
    required this.lifetimePoints,
    required this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      points: json['points'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
      tier: json['tier'] ?? 'bronze',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get tierIcon {
    switch (tier) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  String get tierName {
    return tier[0].toUpperCase() + tier.substring(1);
  }

  int get nextTierPoints {
    switch (tier) {
      case 'bronze':
        return 1000;
      case 'silver':
        return 5000;
      case 'gold':
        return 10000;
      default:
        return 0;
    }
  }

  double get progressToNextTier {
    final next = nextTierPoints;
    if (next == 0) return 1.0;
    return (lifetimePoints % next) / next;
  }
}

class PointsTransaction {
  final String id;
  final String userId;
  final int points;
  final String transactionType;
  final String description;
  final String? bookingId;
  final DateTime createdAt;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.transactionType,
    required this.description,
    this.bookingId,
    required this.createdAt,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      points: json['points'] ?? 0,
      transactionType: json['transaction_type'] ?? 'earned',
      description: json['description'] ?? '',
      bookingId: json['booking_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get icon {
    switch (transactionType) {
      case 'earned':
        return '➕';
      case 'redeemed':
        return '➖';
      case 'bonus':
        return '🎁';
      case 'expired':
        return '⏰';
      default:
        return '💰';
    }
  }
}
