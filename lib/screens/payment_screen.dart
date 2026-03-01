import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final BookingPaymentRequest bookingRequest;
  final String authToken;
  final String userName;
  final String userEmail;
  final String userPhone;

  const PaymentScreen({
    super.key,
    required this.bookingRequest,
    required this.authToken,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentService _paymentService;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  void _initializePayment() {
    _paymentService = PaymentService();
    
    // Handle both mobile (PaymentSuccessResponse) and web (Map) responses
    _paymentService.onPaymentSuccess = (dynamic response) {
      if (response is Map<String, dynamic>) {
        // Web response
        _handlePaymentSuccessWeb(response);
      } else {
        // Mobile response
        _handlePaymentSuccess(response);
      }
    };
    
    _paymentService.onPaymentError = (dynamic response) {
      if (response is Map<String, dynamic>) {
        // Web response
        _handlePaymentErrorWeb(response);
      } else {
        // Mobile response
        _handlePaymentError(response);
      }
    };
    
    _paymentService.onExternalWallet = (dynamic response) {
      if (response is Map<String, dynamic>) {
        // Web response
        _handleExternalWalletWeb(response);
      } else {
        // Mobile response
        _handleExternalWallet(response);
      }
    };
  }

  Future<void> _startPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Create payment order on backend
      final order = await _paymentService.createPaymentOrder(
        bookingRequest: widget.bookingRequest,
        authToken: widget.authToken,
      );

      if (order == null) {
        setState(() {
          _errorMessage = 'Failed to create payment order. Please try again.';
          _isProcessing = false;
        });
        return;
      }

      // Step 2: Open Razorpay checkout
      _paymentService.openCheckout(
        order: order,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
        userName: widget.userName,
      );

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
    });

    // Verify payment on backend
    final verified = await _paymentService.verifyPayment(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
      bookingId: widget.bookingRequest.bookingId,
      authToken: widget.authToken,
    );

    if (verified) {
      // Send payment receipt via email
      await _paymentService.sendPaymentReceipt(
        bookingId: widget.bookingRequest.bookingId,
        authToken: widget.authToken,
      );

      if (mounted) {
        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingId: widget.bookingRequest.bookingId,
              paymentId: response.paymentId ?? '',
              amount: widget.bookingRequest.totalAmount,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Payment verification failed. Please contact support.';
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _errorMessage = 'Payment failed: ${response.message}';
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Web-specific handlers
  void _handlePaymentSuccessWeb(Map<String, dynamic> response) async {
    setState(() {
      _isProcessing = true;
    });

    // Verify payment on backend
    final verified = await _paymentService.verifyPayment(
      paymentId: response['razorpay_payment_id'] ?? '',
      orderId: response['razorpay_order_id'] ?? '',
      signature: response['razorpay_signature'] ?? '',
      bookingId: widget.bookingRequest.bookingId,
      authToken: widget.authToken,
    );

    if (verified) {
      // Send payment receipt via email
      await _paymentService.sendPaymentReceipt(
        bookingId: widget.bookingRequest.bookingId,
        authToken: widget.authToken,
      );

      if (mounted) {
        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingId: widget.bookingRequest.bookingId,
              paymentId: response['razorpay_payment_id'] ?? '',
              amount: widget.bookingRequest.totalAmount,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Payment verification failed. Please contact support.';
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentErrorWeb(Map<String, dynamic> response) {
    setState(() {
      _errorMessage = 'Payment failed: ${response['message'] ?? 'Unknown error'}';
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response['message'] ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleExternalWalletWeb(Map<String, dynamic> response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response['walletName'] ?? 'Unknown'}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF8B1538),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            _buildBookingSummaryCard(),
            const SizedBox(height: 24),
            
            // Price Breakdown Card
            _buildPriceBreakdownCard(),
            const SizedBox(height: 24),
            
            // Payment Info
            _buildPaymentInfoCard(),
            const SizedBox(height: 24),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1538),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pay ₹${widget.bookingRequest.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Secure Payment Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Secure Payment via Razorpay',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Guest Name', widget.bookingRequest.guestName),
            _buildInfoRow('Email', widget.bookingRequest.guestEmail),
            _buildInfoRow('Phone', widget.bookingRequest.guestPhone),
            if (widget.bookingRequest.partnerName != null)
              _buildInfoRow('Partner', widget.bookingRequest.partnerName!),
            _buildInfoRow('Check-in', _formatDate(widget.bookingRequest.checkInDate)),
            _buildInfoRow('Check-out', _formatDate(widget.bookingRequest.checkOutDate)),
            _buildInfoRow('Nights', '${widget.bookingRequest.totalNights}'),
            if (widget.bookingRequest.occasion.isNotEmpty)
              _buildInfoRow('Occasion', widget.bookingRequest.occasion),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildPriceRow(
              'Room (${widget.bookingRequest.totalNights} nights)',
              widget.bookingRequest.roomPrice,
            ),
            if (widget.bookingRequest.addonsPrice > 0)
              _buildPriceRow('Add-ons', widget.bookingRequest.addonsPrice),
            _buildPriceRow('Taxes & Fees', widget.bookingRequest.taxAmount),
            const Divider(height: 24),
            _buildPriceRow(
              'Total Amount',
              widget.bookingRequest.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• This is a TEST MODE payment\n'
              '• Use test card: 4111 1111 1111 1111\n'
              '• Any future date for expiry\n'
              '• Any CVV (e.g., 123)\n'
              '• Payment receipt will be sent to your email',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF8B1538) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String paymentId;
  final double amount;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.paymentId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Your booking has been confirmed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Payment Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailRow('Booking ID', bookingId),
                      const Divider(height: 24),
                      _buildDetailRow('Payment ID', paymentId),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Amount Paid',
                        '₹${amount.toStringAsFixed(2)}',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Info Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment receipt has been sent to your email',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to booking details
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1538),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Booking Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B1538),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? const Color(0xFF8B1538) : Colors.black,
          ),
        ),
      ],
    );
  }
}
