import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import 'api_constants.dart';

class PaymentService {
  late Razorpay _razorpay;
  
  // TEST MODE KEYS - Razorpay Test API Keys
  static const String razorpayTestKeyId = 'rzp_test_RJ8qybQN1ECcEw';
  static const String razorpayTestKeySecret = 'YOUR_TEST_KEY_SECRET';
  
  // TEST MODE FLAG - Set to true for realistic test payments without backend
  static const bool isTestMode = true;
  
  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    debugPrint('📱 Payment Service initialized for Mobile (Test Mode: $isTestMode)');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error: ${response.code} - ${response.message}');
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  /// Create payment order on backend (or simulate in test mode)
  Future<PaymentOrder?> createPaymentOrder({
    required BookingPaymentRequest bookingRequest,
    required String authToken,
  }) async {
    try {
      // TEST MODE: Simulate order creation without backend
      if (isTestMode) {
        debugPrint('🧪 TEST MODE: Simulating payment order creation...');
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        final orderId = 'order_test_${DateTime.now().millisecondsSinceEpoch}';
        final amount = (bookingRequest.totalAmount * 100).toInt(); // Convert to paise
        
        debugPrint('✅ TEST MODE: Order created - $orderId, Amount: ₹${bookingRequest.totalAmount}');
        
        return PaymentOrder(
          orderId: orderId,
          amount: amount,
          currency: 'INR',
          bookingId: bookingRequest.bookingId ?? 'booking_test_${DateTime.now().millisecondsSinceEpoch}',
          status: 'created',
        );
      }
      
      // PRODUCTION MODE: Call actual backend
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/create-order');
      
      final response = await http.post(
        url,
        headers: ApiConstants.headersWithAuth(authToken),
        body: jsonEncode(bookingRequest.toJson()),
      );

      debugPrint('Create Order Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentOrder.fromJson(data['data'] ?? data);
      } else {
        debugPrint('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating payment order: $e');
      return null;
    }
  }

  /// Open Razorpay checkout
  void openCheckout({
    required PaymentOrder order,
    required String userEmail,
    required String userPhone,
    required String userName,
  }) {
    debugPrint('💳 Opening Razorpay Checkout...');
    debugPrint('   Order ID: ${order.orderId}');
    debugPrint('   Amount: ₹${order.amount / 100}');
    debugPrint('   User: $userName ($userEmail)');
    
    var options = {
      'key': razorpayTestKeyId,
      'amount': order.amount,
      'currency': order.currency,
      'name': 'LoveNest',
      'description': 'Hotel Booking Payment',
      'order_id': order.orderId,
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#8B1538',
      },
      'notes': {
        'booking_id': order.bookingId,
      },
      // TEST MODE: Enable test mode features
      'modal': {
        'confirm_close': true,
        'ondismiss': () {
          debugPrint('⚠️ Payment cancelled by user');
        }
      },
    };

    try {
      _razorpay.open(options);
      debugPrint('✅ Razorpay checkout opened successfully');
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🧪 TEST MODE PAYMENT INSTRUCTIONS:');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Use these test card details:');
      debugPrint('');
      debugPrint('✅ SUCCESS CARD:');
      debugPrint('   Card Number: 4111 1111 1111 1111');
      debugPrint('   CVV: Any 3 digits (e.g., 123)');
      debugPrint('   Expiry: Any future date (e.g., 12/25)');
      debugPrint('   Name: Any name');
      debugPrint('');
      debugPrint('❌ FAILURE CARD (to test error handling):');
      debugPrint('   Card Number: 4000 0000 0000 0002');
      debugPrint('   CVV: Any 3 digits');
      debugPrint('   Expiry: Any future date');
      debugPrint('');
      debugPrint('💡 TIP: Payment will be processed instantly in test mode');
      debugPrint('═══════════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Error opening Razorpay: $e');
    }
  }

  /// Verify payment signature on backend (or simulate in test mode)
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required String bookingId,
    required String authToken,
  }) async {
    try {
      // TEST MODE: Simulate verification without backend
      if (isTestMode) {
        debugPrint('🧪 TEST MODE: Simulating payment verification...');
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate processing
        
        debugPrint('✅ TEST MODE: Payment verified successfully');
        debugPrint('   Payment ID: $paymentId');
        debugPrint('   Order ID: $orderId');
        debugPrint('   Booking ID: $bookingId');
        
        return true; // Always succeed in test mode
      }
      
      // PRODUCTION MODE: Call actual backend
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/verify');
      
      final response = await http.post(
        url,
        headers: ApiConstants.headersWithAuth(authToken),
        body: jsonEncode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
          'booking_id': bookingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true || data['verified'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return isTestMode; // Return true in test mode even on error
    }
  }

  /// Get payment details (or simulate in test mode)
  Future<PaymentDetails?> getPaymentDetails({
    required String bookingId,
    required String authToken,
  }) async {
    try {
      // TEST MODE: Simulate payment details
      if (isTestMode) {
        debugPrint('🧪 TEST MODE: Simulating payment details fetch...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        return PaymentDetails(
          paymentId: 'pay_test_${Random().nextInt(999999)}',
          orderId: 'order_test_${Random().nextInt(999999)}',
          amount: 5000, // Example amount
          currency: 'INR',
          status: 'captured',
          method: 'card',
          createdAt: DateTime.now(),
        );
      }
      
      // PRODUCTION MODE: Call actual backend
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/$bookingId');
      
      final response = await http.get(
        url,
        headers: ApiConstants.headersWithAuth(authToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentDetails.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching payment details: $e');
      return null;
    }
  }

  /// Send payment receipt via email (or simulate in test mode)
  Future<bool> sendPaymentReceipt({
    required String bookingId,
    required String authToken,
  }) async {
    try {
      // TEST MODE: Simulate receipt sending
      if (isTestMode) {
        debugPrint('🧪 TEST MODE: Simulating receipt email...');
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ TEST MODE: Receipt email sent (simulated)');
        return true;
      }
      
      // PRODUCTION MODE: Call actual backend
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/send-receipt');
      
      final response = await http.post(
        url,
        headers: ApiConstants.headersWithAuth(authToken),
        body: jsonEncode({
          'booking_id': bookingId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending receipt: $e');
      return isTestMode; // Return true in test mode
    }
  }

  /// Process refund (or simulate in test mode)
  Future<bool> processRefund({
    required String paymentId,
    required String bookingId,
    required int amount,
    required String reason,
    required String authToken,
  }) async {
    try {
      // TEST MODE: Simulate refund processing
      if (isTestMode) {
        debugPrint('🧪 TEST MODE: Simulating refund...');
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ TEST MODE: Refund processed (simulated)');
        debugPrint('   Amount: ₹${amount / 100}');
        debugPrint('   Reason: $reason');
        return true;
      }
      
      // PRODUCTION MODE: Call actual backend
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/refund');
      
      final response = await http.post(
        url,
        headers: ApiConstants.headersWithAuth(authToken),
        body: jsonEncode({
          'payment_id': paymentId,
          'booking_id': bookingId,
          'amount': amount,
          'reason': reason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error processing refund: $e');
      return isTestMode; // Return true in test mode
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
