import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/screens/payment_screen.dart';
import 'package:lovenest/models/payment_model.dart';

class BookingScreen extends StatefulWidget {
  final String hotelId;
  const BookingScreen({super.key, required this.hotelId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _bookAnonymously = false;
  
  bool _addonCandlelight = false;
  bool _addonRoses = false;
  bool _addonLateCheckout = false;

  final double _basePrice = 250.0; // Mock base price

  double get _totalPrice {
    double total = _basePrice;
    if (_addonCandlelight) total += 50;
    if (_addonRoses) total += 30;
    if (_addonLateCheckout) total += 40;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Nest'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
            Text('Select Dates', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    title: 'Check In',
                    date: _checkInDate,
                    onTap: () async {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: _checkInDate ?? today,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        }
                      );
                      if (selected != null) {
                        setState(() {
                          _checkInDate = selected;
                          // Reset check-out date if it is now before or same as check-in
                          if (_checkOutDate != null && !_checkOutDate!.isAfter(_checkInDate!)) {
                             _checkOutDate = _checkInDate!.add(const Duration(days: 1));
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    title: 'Check Out',
                    date: _checkOutDate,
                    onTap: () async {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final checkIn = _checkInDate ?? today;
                      final minCheckOut = checkIn.add(const Duration(days: 1));
                      
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: _checkOutDate != null && _checkOutDate!.isAfter(minCheckOut) 
                            ? _checkOutDate! 
                            : minCheckOut,
                        firstDate: minCheckOut,
                        lastDate: minCheckOut.add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        }
                      );
                      if (selected != null) {
                        setState(() => _checkOutDate = selected);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Privacy Add-on
            Text('Privacy Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: SwitchListTile(
                value: _bookAnonymously,
                onChanged: (val) => setState(() => _bookAnonymously = val),
                 activeThumbColor: AppColors.primary,
                title: Text('Book Anonymously', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: const Text('Hide your name from the hotel staff for ultimate privacy'),
                secondary: const Icon(Icons.security, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),

            // Romantic Add-ons
            Text('Romantic Add-ons', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAddonTile(
              title: 'Candlelight Setup (+\$50)',
              icon: Icons.lightbulb_outline,
              value: _addonCandlelight,
              onChanged: (val) => setState(() => _addonCandlelight = val!),
            ),
            _buildAddonTile(
              title: 'Rose Decoration (+\$30)',
              icon: Icons.local_florist,
              value: _addonRoses,
              onChanged: (val) => setState(() => _addonRoses = val!),
            ),
            _buildAddonTile(
              title: 'Late Checkout (+\$40)',
              icon: Icons.schedule,
              value: _addonLateCheckout,
              onChanged: (val) => setState(() => _addonLateCheckout = val!),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  Text(
                    '\$$_totalPrice',
                    style: theme.textTheme.displayMedium?.copyWith(color: AppColors.primary, fontSize: 24),
                  ),
                ],
              ),
              SizedBox(
                width: 180,
                height: 56,
                child: ElevatedButton(
                  onPressed: _checkInDate != null && _checkOutDate != null
                      ? () => _proceedToPayment()
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('Proceed to Pay'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({required String title, required DateTime? date, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
             const SizedBox(height: 8),
             Text(
               date != null ? '${date.day}/${date.month}/${date.year}' : 'Select Date',
               style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: date != null ? AppColors.primary : null),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonTile({required String title, required IconData icon, required bool value, required ValueChanged<bool?> onChanged}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? AppColors.primary : Colors.transparent),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        secondary: Container(
           padding: const EdgeInsets.all(8),
           decoration: BoxDecoration(
             color: AppColors.primary.withOpacity(0.1),
             shape: BoxShape.circle,
           ),
           child: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to continue'),
          backgroundColor: Colors.red,
        ),
      );
      context.go('/login');
      return;
    }

    // Calculate nights
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    
    // Calculate prices
    final roomPrice = _basePrice * nights;
    double addonsPrice = 0;
    List<String> selectedAddons = [];
    
    if (_addonCandlelight) {
      addonsPrice += 50;
      selectedAddons.add('Candlelight Setup');
    }
    if (_addonRoses) {
      addonsPrice += 30;
      selectedAddons.add('Rose Decoration');
    }
    if (_addonLateCheckout) {
      addonsPrice += 40;
      selectedAddons.add('Late Checkout');
    }
    
    final subtotal = roomPrice + addonsPrice;
    final taxAmount = subtotal * 0.15; // 15% tax
    final totalAmount = subtotal + taxAmount;

    // Create booking request
    final bookingRequest = BookingPaymentRequest(
      bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
      hotelId: widget.hotelId,
      roomId: 'RM001', // You can make this dynamic based on room selection
      userId: user['id'] ?? '',
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      totalNights: nights,
      roomPrice: roomPrice,
      addonsPrice: addonsPrice,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      addons: selectedAddons,
      occasion: '', // You can add an occasion field if needed
      specialRequests: _bookAnonymously ? 'Book anonymously - Hide guest name' : '',
      guestName: user['name'] ?? user['email'] ?? 'Guest',
      guestEmail: user['email'] ?? '',
      guestPhone: user['phone'] ?? '+919999999999',
      partnerName: null,
    );

    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingRequest: bookingRequest,
          authToken: authService.accessToken ?? '',
          userName: user['name'] ?? user['email'] ?? 'Guest',
          userEmail: user['email'] ?? '',
          userPhone: user['phone'] ?? '+919999999999',
        ),
      ),
    );
  }
}
