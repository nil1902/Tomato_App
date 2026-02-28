class Coupon {
  final String id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double? minBookingAmount;
  final double? maxDiscount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minBookingAmount,
    this.maxDiscount,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      minBookingAmount: json['min_booking_amount']?.toDouble(),
      maxDiscount: json['max_discount']?.toDouble(),
      validFrom: json['valid_from'] != null ? DateTime.parse(json['valid_from']) : null,
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
      usageLimit: json['usage_limit'],
      usedCount: json['used_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    return true;
  }

  double calculateDiscount(double bookingAmount) {
    if (!isValid) return 0;
    if (minBookingAmount != null && bookingAmount < minBookingAmount!) return 0;

    double discount = 0;
    if (discountType == 'percentage') {
      discount = bookingAmount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }

    return discount;
  }
}
