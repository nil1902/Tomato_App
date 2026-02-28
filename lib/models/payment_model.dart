class PaymentOrder {
  final String orderId;
  final String bookingId;
  final int amount; // Amount in paise (INR)
  final String currency;
  final String receipt;
  final DateTime createdAt;
  final String status;

  PaymentOrder({
    required this.orderId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    this.receipt = '',
    DateTime? createdAt,
    this.status = 'created',
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['order_id'] ?? json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'booking_id': bookingId,
      'amount': amount,
      'currency': currency,
      'receipt': receipt,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaymentDetails {
  final String paymentId;
  final String orderId;
  final String signature;
  final String bookingId;
  final int amount;
  final String currency;
  final String status;
  final String method;
  final DateTime createdAt;

  PaymentDetails({
    required this.paymentId,
    required this.orderId,
    this.signature = '',
    this.bookingId = '',
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      paymentId: json['payment_id'] ?? '',
      orderId: json['order_id'] ?? '',
      signature: json['signature'] ?? '',
      bookingId: json['booking_id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? 'pending',
      method: json['method'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'signature': signature,
      'booking_id': bookingId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'method': method,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class BookingPaymentRequest {
  final String bookingId;
  final String hotelId;
  final String roomId;
  final String userId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalNights;
  final double roomPrice;
  final double addonsPrice;
  final double taxAmount;
  final double totalAmount;
  final List<String> addons;
  final String occasion;
  final String specialRequests;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String? partnerName;

  BookingPaymentRequest({
    required this.bookingId,
    required this.hotelId,
    required this.roomId,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.roomPrice,
    required this.addonsPrice,
    required this.taxAmount,
    required this.totalAmount,
    required this.addons,
    required this.occasion,
    required this.specialRequests,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    this.partnerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'user_id': userId,
      'checkin_date': checkInDate.toIso8601String(),
      'checkout_date': checkOutDate.toIso8601String(),
      'total_nights': totalNights,
      'room_price': roomPrice,
      'addons_price': addonsPrice,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'addons': addons,
      'occasion': occasion,
      'special_requests': specialRequests,
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'partner_name': partnerName,
    };
  }
}

class PaymentReceipt {
  final String receiptId;
  final String bookingId;
  final String hotelName;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double roomTotal;
  final double addonsTotal;
  final double taxTotal;
  final double grandTotal;
  final String paymentMethod;
  final String transactionId;
  final DateTime paymentDate;
  final String guestName;
  final String guestEmail;

  PaymentReceipt({
    required this.receiptId,
    required this.bookingId,
    required this.hotelName,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.roomTotal,
    required this.addonsTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentDate,
    required this.guestName,
    required this.guestEmail,
  });

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    return PaymentReceipt(
      receiptId: json['receipt_id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      hotelName: json['hotel_name'] ?? '',
      roomType: json['room_type'] ?? '',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      nights: json['nights'] ?? 0,
      roomTotal: (json['room_total'] ?? 0).toDouble(),
      addonsTotal: (json['addons_total'] ?? 0).toDouble(),
      taxTotal: (json['tax_total'] ?? 0).toDouble(),
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      paymentDate: DateTime.parse(json['payment_date']),
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'] ?? '',
    );
  }
}
