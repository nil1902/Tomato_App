import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class AccountSettingsScreenModern extends StatefulWidget {
  const AccountSettingsScreenModern({super.key});

  @override
  State<AccountSettingsScreenModern> createState() => _AccountSettingsScreenModernState();
}

class _AccountSettingsScreenModernState extends State<AccountSettingsScreenModern> {
  bool _bookingConfirmations = true;
  bool _priceDropAlerts = true;
  bool _romanticOffers = false;
  bool _anonymousReviews = true;
  bool _hideProfilePhoto = false;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF221016) : const Color(0xFFF8F6F6),
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account & Security
          _buildSectionHeader(context, 'ACCOUNT & SECURITY'),
          _buildSection(
            context,
            children: [
              _buildListTile(
                context,
                title: 'Change Password',
                subtitle: 'Last changed 3 months ago',
                icon: Icons.lock,
                iconColor: AppColors.primary,
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildDivider(),
              _buildListTile(
                context,
                title: 'Active Sessions',
                subtitle: 'iPhone 14 Pro, MacBook Air',
                icon: Icons.devices,
                iconColor: AppColors.primary,
                onTap: () => _showLoginHistory(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications
          _buildSectionHeader(context, 'NOTIFICATIONS'),
          _buildSection(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Booking Confirmations',
                icon: Icons.confirmation_number,
                iconColor: AppColors.primary,
                value: _bookingConfirmations,
                onChanged: (val) => setState(() => _bookingConfirmations = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                title: 'Price Drop Alerts',
                icon: Icons.price_change,
                iconColor: AppColors.primary,
                value: _priceDropAlerts,
                onChanged: (val) => setState(() => _priceDropAlerts = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                title: 'Romantic Offers',
                icon: Icons.favorite,
                iconColor: AppColors.primary,
                value: _romanticOffers,
                onChanged: (val) => setState(() => _romanticOffers = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy
          _buildSectionHeader(context, 'PRIVACY'),
          _buildSection(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Anonymous Reviews',
                icon: Icons.visibility_off,
                iconColor: AppColors.primary,
                value: _anonymousReviews,
                onChanged: (val) => setState(() => _anonymousReviews = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                title: 'Hide Profile Photo',
                icon: Icons.account_circle,
                iconColor: AppColors.primary,
                value: _hideProfilePhoto,
                onChanged: (val) => setState(() => _hideProfilePhoto = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // App Preferences
          _buildSectionHeader(context, 'APP PREFERENCES'),
          _buildSection(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Dark Mode',
                icon: Icons.dark_mode,
                iconColor: AppColors.primary,
                value: _darkMode,
                onChanged: (val) => setState(() => _darkMode = val),
              ),
              _buildDivider(),
              _buildListTile(
                context,
                title: 'Currency',
                subtitle: 'USD (\$)',
                icon: Icons.currency_exchange,
                iconColor: AppColors.primary,
                onTap: () => _showCurrencyDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Delete Account
          OutlinedButton(
            onPressed: () => _showDeleteAccountDialog(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.1)),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(leading: const Icon(Icons.devices), title: const Text('Windows PC'), subtitle: const Text('New York, USA • 2 hours ago')),
              ListTile(leading: const Icon(Icons.devices), title: const Text('iPhone 14'), subtitle: const Text('New York, USA • 1 day ago')),
              ListTile(leading: const Icon(Icons.devices), title: const Text('Android Phone'), subtitle: const Text('Los Angeles, USA • 3 days ago')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(title: const Text('INR (₹)'), value: 'INR', groupValue: 'USD', onChanged: (val) {}),
            RadioListTile<String>(title: const Text('USD (\$)'), value: 'USD', groupValue: 'USD', onChanged: (val) {}),
            RadioListTile<String>(title: const Text('EUR (€)'), value: 'EUR', groupValue: 'USD', onChanged: (val) {}),
            RadioListTile<String>(title: const Text('GBP (£)'), value: 'GBP', groupValue: 'USD', onChanged: (val) {}),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.textSecondary.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, Icons.search, 'Explore', false, () => context.push('/home')),
              _buildNavItem(context, Icons.favorite, 'Saved', false, () => context.push('/wishlist')),
              _buildNavItem(context, Icons.calendar_today, 'Bookings', false, () => context.push('/bookings')),
              _buildNavItem(context, Icons.settings, 'Settings', true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? AppColors.primary : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
