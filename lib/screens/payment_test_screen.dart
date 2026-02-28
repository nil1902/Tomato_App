import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payment_screen.dart';

/// Test screen to quickly test payment integration
/// Remove this file in production
class PaymentTestScreen extends StatefulWidget {
  final String authToken;
  final String userName;
  final String userEmail;
  final String userPhone;

  const PaymentTestScreen({
    Key? key,
    required this.authToken,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  }) : super(key: key);

  @override
  State<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends State<PaymentTestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _hotelNameController = TextEditingController(text: 'Romantic Paradise Resort');
  final _roomTypeController = TextEditingController(text: 'Deluxe Suite with Jacuzzi');
  final _guestNameController = TextEditingController(text: 'John Doe');
  final _partnerNameController = TextEditingController(text: 'Jane Doe');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nightsController = TextEditingController(text: '2');
  final _roomPriceController = TextEditingController(text: '4000');
  final _addonsPriceController = TextEditingController(text: '1500');
  
  String _selectedOccasion = 'Anniversary';
  final List<String> _occasions = [
    'Anniversary',
    'Honeymoon',
    'Birthday',
    'Weekend Getaway',
    'Just Us',
  ];
  
  final List<String> _selectedAddons = [];
  final Map<String, bool> _addons = {
    'Rose Petal Decoration': false,
    'Candlelight Dinner': false,
    'Couple Massage': false,
    'Champagne on Arrival': false,
    'Anniversary Cake': false,
  };

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userEmail;
    _phoneController.text = widget.userPhone;
  }

  @override
  void dispose() {
    _hotelNameController.dispose();
    _roomTypeController.dispose();
    _guestNameController.dispose();
    _partnerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nightsController.dispose();
    _roomPriceController.dispose();
    _addonsPriceController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_formKey.currentState!.validate()) {
      final nights = int.parse(_nightsController.text);
      final roomPrice = double.parse(_roomPriceController.text) * nights;
      final addonsPrice = double.parse(_addonsPriceController.text);
      final taxAmount = (roomPrice + addonsPrice) * 0.15; // 15% tax
      final totalAmount = roomPrice + addonsPrice + taxAmount;

      final bookingRequest = BookingPaymentRequest(
        bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
        hotelId: 'HTL_TEST_001',
        roomId: 'RM_TEST_001',
        userId: 'USR_TEST_001',
        checkInDate: DateTime.now().add(const Duration(days: 7)),
        checkOutDate: DateTime.now().add(Duration(days: 7 + nights)),
        totalNights: nights,
        roomPrice: roomPrice,
        addonsPrice: addonsPrice,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        addons: _selectedAddons,
        occasion: _selectedOccasion,
        specialRequests: 'Test booking - Please handle with care',
        guestName: _guestNameController.text,
        guestEmail: _emailController.text,
        guestPhone: _phoneController.text,
        partnerName: _partnerNameController.text.isEmpty 
            ? null 
            : _partnerNameController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingRequest: bookingRequest,
            authToken: widget.authToken,
            userName: widget.userName,
            userEmail: _emailController.text,
            userPhone: _phoneController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Payment Integration'),
        backgroundColor: const Color(0xFF8B1538),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TEST MODE ONLY - Remove this screen in production',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hotel Details Section
            const Text(
              'Hotel Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hotelNameController,
              decoration: const InputDecoration(
                labelText: 'Hotel Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomTypeController,
              decoration: const InputDecoration(
                labelText: 'Room Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // Guest Details Section
            const Text(
              'Guest Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(
                labelText: 'Guest Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _partnerNameController,
              decoration: const InputDecoration(
                labelText: 'Partner Name (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (value!.length < 10) return 'Invalid phone';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Booking Details Section
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nightsController,
              decoration: const InputDecoration(
                labelText: 'Number of Nights',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (int.tryParse(value!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomPriceController,
              decoration: const InputDecoration(
                labelText: 'Room Price per Night (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedOccasion,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                border: OutlineInputBorder(),
              ),
              items: _occasions.map((occasion) {
                return DropdownMenuItem(
                  value: occasion,
                  child: Text(occasion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOccasion = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Add-ons Section
            const Text(
              'Romantic Add-ons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._addons.keys.map((addon) {
              return CheckboxListTile(
                title: Text(addon),
                value: _addons[addon],
                onChanged: (value) {
                  setState(() {
                    _addons[addon] = value!;
                    if (value) {
                      _selectedAddons.add(addon);
                    } else {
                      _selectedAddons.remove(addon);
                    }
                  });
                },
                activeColor: const Color(0xFF8B1538),
              );
            }).toList(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addonsPriceController,
              decoration: const InputDecoration(
                labelText: 'Total Add-ons Price (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Price Summary
            _buildPriceSummary(),
            const SizedBox(height: 24),

            // Test Card Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Test Card Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Card: 4111 1111 1111 1111\n'
                    'Expiry: Any future date\n'
                    'CVV: Any 3 digits (e.g., 123)',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proceed Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1538),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final nights = int.tryParse(_nightsController.text) ?? 0;
    final roomPrice = (double.tryParse(_roomPriceController.text) ?? 0) * nights;
    final addonsPrice = double.tryParse(_addonsPriceController.text) ?? 0;
    final taxAmount = (roomPrice + addonsPrice) * 0.15;
    final totalAmount = roomPrice + addonsPrice + taxAmount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildPriceRow('Room ($nights nights)', roomPrice),
            _buildPriceRow('Add-ons', addonsPrice),
            _buildPriceRow('Taxes & Fees (15%)', taxAmount),
            const Divider(height: 24),
            _buildPriceRow('Total Amount', totalAmount, isTotal: true),
          ],
        ),
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
}
