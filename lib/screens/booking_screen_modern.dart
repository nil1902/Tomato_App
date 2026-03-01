import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/screens/payment_screen.dart';
import 'package:lovenest/models/payment_model.dart';

class BookingScreenModern extends StatefulWidget {
  final String hotelId;
  const BookingScreenModern({super.key, required this.hotelId});

  @override
  State<BookingScreenModern> createState() => _BookingScreenModernState();
}

class _BookingScreenModernState extends State<BookingScreenModern> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedOccasion;
  
  bool _addonRosePetals = false;
  bool _addonChampagne = true;
  bool _addonCake = false;
  bool _addonSpa = false;

  final double _basePrice = 280.0;
  final Map<String, double> _addonPrices = {
    'rose_petals': 25.0,
    'champagne': 60.0,
    'cake': 30.0,
    'spa': 120.0,
  };

  double get _addonsTotal {
    double total = 0;
    if (_addonRosePetals) total += _addonPrices['rose_petals']!;
    if (_addonChampagne) total += _addonPrices['champagne']!;
    if (_addonCake) total += _addonPrices['cake']!;
    if (_addonSpa) total += _addonPrices['spa']!;
    return total;
  }

  double get _totalPrice => _basePrice + _addonsTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF230F13) : const Color(0xFFF8F5F6),
      appBar: AppBar(
        title: const Text('Personalize Stay', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Steps
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Container(width: 32, height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 12),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 32),

            // Header
            Text('Make it unforgettable', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Choose premium add-ons to surprise your partner upon arrival.', 
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Occasion Select
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Special Occasion', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOccasion,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF230F13) : const Color(0xFFF8F5F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                      ),
                    ),
                    hint: const Text('Select an occasion...'),
                    items: const [
                      DropdownMenuItem(value: 'anniversary', child: Text('Anniversary')),
                      DropdownMenuItem(value: 'birthday', child: Text('Birthday')),
                      DropdownMenuItem(value: 'honeymoon', child: Text('Honeymoon')),
                      DropdownMenuItem(value: 'proposal', child: Text('Proposal')),
                      DropdownMenuItem(value: 'just_because', child: Text('Just Because')),
                    ],
                    onChanged: (value) => setState(() => _selectedOccasion = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Add-ons Header
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Popular Upgrades', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Add-ons List
            _buildAddonCard(
              context,
              title: 'Rose Petal Decor',
              description: 'Romantic arrangement on bed and bath.',
              price: 25,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKBzQOs1E4VEoEs1OwyvtgRv3Q3jthkUX4syf4VbngK44CcXfYqQTFj8x4cTtns8indyXgq2wklYWrhPquKS4BeQAtPtnzeKWa8X8X7lDj2ZwXxLW048nfbqOnWWipn8Y-22NvwSA-mcUOQ-lsqaqwrAy6WL6djQZf6RqY1O3DH9V_0A8r2WzhLf-HY48eM-8k1RG04sBOQJNXdPU_3UHOKixlBqbapQNuwTAF6TpLFmnTQ7hw2I2G3UXxeaFeS1_7F1KpPTAEP8s',
              isSelected: _addonRosePetals,
              onToggle: () => setState(() => _addonRosePetals = !_addonRosePetals),
            ),
            const SizedBox(height: 16),
            _buildAddonCard(
              context,
              title: 'Chilled Champagne',
              description: 'Premium bubbly waiting on ice.',
              price: 60,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCzz0YBwg12CTOW1bRfkItqQ-nc_Q4vQOavIaP8LinFMu4oTFsDU4yiSySKteAeGkkw4Rdh93YblZLk9lYGVvce_TyPiGasQMGkQGgAvg5R0AqThqFK0iQgW5Wvp-t6Ly_PFDlbyBnMx-cYJKYxqprmlvNkTY7535Fo-59o9Ypmz2JNyyOKDykjp1Idk0msS5Ml0-i0Ta91_8OSW_sR0wKcUySKdf1s5bEmnbl2oB14cT58M2swjLoU9vGM5hiVx8rSglj_XKr8jRE',
              isSelected: _addonChampagne,
              onToggle: () => setState(() => _addonChampagne = !_addonChampagne),
            ),
            const SizedBox(height: 16),
            _buildAddonCard(
              context,
              title: 'Midnight Cake',
              description: 'Delicious gourmet cake for two.',
              price: 30,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAf0pcWph0U3KY2cEoozxIcNAQYw0Y-XDAQOi8k28eNgKPixmilDZPiMGUzC69XaqTQqxG2GK4VenMhZoDATpye5NEslvBBIEFI4POguLmrp070RiQNqoIFlXXd-FY9jUJtA2K8hJLjRvQCd5WpTt0KbsYtPlMWTNuxjuBt1sOqArj4s0g_0oWfKUPtvZ6RvOvtyatHtIWJfQRqO6Md5Kd0I6K3CAY9BujXsJfH44r6QL8XayJSFU9TEhATkZoqVK30sS-65tpPERg',
              isSelected: _addonCake,
              onToggle: () => setState(() => _addonCake = !_addonCake),
            ),
            const SizedBox(height: 16),
            _buildAddonCard(
              context,
              title: 'Couple Spa',
              description: '60-min relaxing massage session.',
              price: 120,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCB53LFx7TkCV6p7PLKiD7e5zls0c4Wm6wzNrRiWimHenM3obb1s2cv4cq8b3_ZykAfFEilpw_8eB2ZUkq5scVs5DiWweWRNfwqB6MmHmv3IbwPkpGllDb6_EqlERCG4ehnwsOf_A1LT_DzXCws6aQAIb6NwOcg92nyCSbGZcwa9lb3NJzdlE-WKgcaeqUVWMcGxi17pxeaV2rdWa5h6k8_4RiMmsPGbfTDEuXTn5vBHjMaY_ftmn5x1IU8nDNxVVNuyvc5NwBoKUY',
              isSelected: _addonSpa,
              onToggle: () => setState(() => _addonSpa = !_addonSpa),
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Price', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      Row(
                        children: [
                          Text('\$$_totalPrice', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('(\$$_basePrice + \$$_addonsTotal add-ons)', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showBreakdown(context),
                    child: const Text('View breakdown', style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _proceedToPayment(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Proceed to Payment'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildAddonCard(BuildContext context, {
    required String title,
    required String description,
    required int price,
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.image, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                      Text('\$$price', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.check : Icons.add,
                          size: 14,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSelected ? 'Added' : 'Add to stay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildBreakdownRow('Room (1 night)', '\$$_basePrice'),
            if (_addonRosePetals) _buildBreakdownRow('Rose Petal Decor', '\$${_addonPrices['rose_petals']}'),
            if (_addonChampagne) _buildBreakdownRow('Chilled Champagne', '\$${_addonPrices['champagne']}'),
            if (_addonCake) _buildBreakdownRow('Midnight Cake', '\$${_addonPrices['cake']}'),
            if (_addonSpa) _buildBreakdownRow('Couple Spa', '\$${_addonPrices['spa']}'),
            const Divider(height: 32),
            _buildBreakdownRow('Total', '\$$_totalPrice', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? AppColors.primary : null)),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue'), backgroundColor: Colors.red),
      );
      context.go('/login');
      return;
    }

    // Calculate prices
    final nights = 1;
    final roomPrice = _basePrice * nights;
    final addonsPrice = _addonsTotal;
    final subtotal = roomPrice + addonsPrice;
    final taxAmount = subtotal * 0.15;
    final totalAmount = subtotal + taxAmount;

    List<String> selectedAddons = [];
    if (_addonRosePetals) selectedAddons.add('Rose Petal Decor');
    if (_addonChampagne) selectedAddons.add('Chilled Champagne');
    if (_addonCake) selectedAddons.add('Midnight Cake');
    if (_addonSpa) selectedAddons.add('Couple Spa');

    final bookingRequest = BookingPaymentRequest(
      bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
      hotelId: widget.hotelId,
      roomId: 'RM001',
      userId: user['id'] ?? '',
      checkInDate: _checkInDate ?? DateTime.now(),
      checkOutDate: _checkOutDate ?? DateTime.now().add(const Duration(days: 1)),
      totalNights: nights,
      roomPrice: roomPrice,
      addonsPrice: addonsPrice,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      addons: selectedAddons,
      occasion: _selectedOccasion ?? '',
      specialRequests: '',
      guestName: user['name'] ?? user['email'] ?? 'Guest',
      guestEmail: user['email'] ?? '',
      guestPhone: user['phone'] ?? '+919999999999',
      partnerName: null,
    );

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
