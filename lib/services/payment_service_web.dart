import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import 'api_constants.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;

class PaymentService {
  // TEST MODE KEYS - Razorpay Test API Keys
  static const String razorpayTestKeyId = 'rzp_test_RJ8qybQN1ECcEw';
  static const String razorpayTestKeySecret = 'YOUR_TEST_KEY_SECRET';
  
  // Callbacks
  Function(Map<String, dynamic>)? onPaymentSuccess;
  Function(Map<String, dynamic>)? onPaymentError;
  Function(Map<String, dynamic>)? onExternalWallet;

  PaymentService() {
    debugPrint('🌐 Payment Service initialized for Web');
  }

  /// Create payment order on backend
  Future<PaymentOrder?> createPaymentOrder({
    required BookingPaymentRequest bookingRequest,
    required String authToken,
  }) async {
    try {
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

  /// Open Razorpay checkout for web
  void openCheckout({
    required PaymentOrder order,
    required String userEmail,
    required String userPhone,
    required String userName,
  }) {
    try {
      // For web, we'll use a simulated payment for now
      // In production, you would integrate Razorpay Web SDK
      debugPrint('🌐 Opening web payment checkout');
      
      // Simulate payment dialog
      _showWebPaymentDialog(
        order: order,
        userEmail: userEmail,
        userPhone: userPhone,
        userName: userName,
      );
    } catch (e) {
      debugPrint('Error opening web checkout: $e');
      if (onPaymentError != null) {
        onPaymentError!({
          'code': 'WEB_ERROR',
          'message': 'Payment initialization failed: $e',
        });
      }
    }
  }

  void _showWebPaymentDialog({
    required PaymentOrder order,
    required String userEmail,
    required String userPhone,
    required String userName,
  }) {
    // This is a placeholder for web payment
    // In production, integrate Razorpay Web Checkout
    debugPrint('💳 Web Payment Dialog');
    debugPrint('Amount: ₹${order.amount / 100}');
    debugPrint('Order ID: ${order.orderId}');
    
    // For now, simulate successful payment after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (onPaymentSuccess != null) {
        onPaymentSuccess!({
          'razorpay_payment_id': 'pay_web_${DateTime.now().millisecondsSinceEpoch}',
          'razorpay_order_id': order.orderId,
          'razorpay_signature': 'sig_web_test',
        });
      }
    });
  }

  /// Verify payment signature on backend
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required String bookingId,
    required String authToken,
  }) async {
    try {
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

      debugPrint('Verify Payment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true || data['verified'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }

  /// Get payment details
  Future<PaymentDetails?> getPaymentDetails({
    required String bookingId,
    required String authToken,
  }) async {
    try {
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

  /// Send payment receipt via email
  Future<bool> sendPaymentReceipt({
    required String bookingId,
    required String authToken,
  }) async {
    try {
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
      return false;
    }
  }

  /// Process refund
  Future<bool> processRefund({
    required String paymentId,
    required String bookingId,
    required int amount,
    required String reason,
    required String authToken,
  }) async {
    try {
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
      return false;
    }
  }

  void dispose() {
    debugPrint('🌐 Web Payment Service disposed');
  }
}
