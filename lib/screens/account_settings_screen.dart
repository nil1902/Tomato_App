import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = true;
  bool _twoFactorAuth = false;
  bool _biometricLogin = false;
  bool _shareDataWithPartners = false;
  bool _personalizedAds = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          if (user != null) _buildUserInfoCard(context, user),
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: 'Privacy & Security',
            icon: Icons.security,
            color: Colors.blue,
            children: [
              _buildSwitchTile(
                context,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security to your account',
                value: _twoFactorAuth,
                onChanged: (val) => setState(() => _twoFactorAuth = val),
              ),
              _buildSwitchTile(
                context,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face recognition',
                value: _biometricLogin,
                onChanged: (val) => setState(() => _biometricLogin = val),
              ),
              _buildListTile(
                context,
                title: 'Change Password',
                subtitle: 'Update your account password',
                icon: Icons.lock_outline,
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Login History',
                subtitle: 'View recent login activity and devices',
                icon: Icons.history,
                onTap: () => _showLoginHistory(context),
              ),
              _buildListTile(
                context,
                title: 'Safety Centre',
                subtitle: 'Safety tips and emergency contacts',
                icon: Icons.shield_outlined,
                onTap: () => context.push('/safety-centre'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Notification Preferences',
            icon: Icons.notifications_outlined,
            color: Colors.orange,
            children: [
              _buildSwitchTile(
                context,
                title: 'Email Notifications',
                subtitle: 'Booking confirmations, updates, and receipts',
                value: _emailNotifications,
                onChanged: (val) => setState(() => _emailNotifications = val),
              ),
              _buildSwitchTile(
                context,
                title: 'Push Notifications',
                subtitle: 'Real-time alerts on your device',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              _buildSwitchTile(
                context,
                title: 'SMS Notifications',
                subtitle: 'Text messages for important booking updates',
                value: _smsNotifications,
                onChanged: (val) => setState(() => _smsNotifications = val),
              ),
              _buildSwitchTile(
                context,
                title: 'Marketing Communications',
                subtitle: 'Special offers, deals, and romantic getaway ideas',
                value: _marketingEmails,
                onChanged: (val) => setState(() => _marketingEmails = val),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Data & Privacy',
            icon: Icons.privacy_tip_outlined,
            color: Colors.green,
            children: [
              _buildSwitchTile(
                context,
                title: 'Personalized Recommendations',
                subtitle: 'Get hotel suggestions based on your preferences',
                value: _personalizedAds,
                onChanged: (val) => setState(() => _personalizedAds = val),
              ),
              _buildSwitchTile(
                context,
                title: 'Share Analytics Data',
                subtitle: 'Help us improve your experience (anonymous)',
                value: _shareDataWithPartners,
                onChanged: (val) => setState(() => _shareDataWithPartners = val),
              ),
              _buildListTile(
                context,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy and data protection policy',
                icon: Icons.policy,
                onTap: () => context.push('/privacy-policy'),
              ),
              _buildListTile(
                context,
                title: 'Download My Data',
                subtitle: 'Request a copy of your personal information',
                icon: Icons.download,
                onTap: () => _showDownloadDataDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account and data',
                icon: Icons.delete_forever,
                iconColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Payment & Billing',
            icon: Icons.payment,
            color: AppColors.primary,
            children: [
              _buildListTile(
                context,
                title: 'Saved Payment Methods',
                subtitle: 'Manage your cards and payment options',
                icon: Icons.credit_card,
                onTap: () => _showSavedCards(context),
              ),
              _buildListTile(
                context,
                title: 'Billing Address',
                subtitle: 'Update your billing information',
                icon: Icons.location_on_outlined,
                onTap: () => _showBillingAddressDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Transaction History',
                subtitle: 'View all your payment transactions',
                icon: Icons.receipt_long,
                onTap: () => _showTransactionHistory(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Legal & Policies',
            icon: Icons.gavel,
            color: Colors.purple,
            children: [
              _buildListTile(
                context,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                icon: Icons.description,
                onTap: () => context.push('/terms-conditions'),
              ),
              _buildListTile(
                context,
                title: 'Cancellation Policy',
                subtitle: 'Understand our booking cancellation rules',
                icon: Icons.cancel,
                onTap: () => _showCancellationPolicy(context),
              ),
              _buildListTile(
                context,
                title: 'Community Guidelines',
                subtitle: 'Rules for reviews and user conduct',
                icon: Icons.people,
                onTap: () => _showCommunityGuidelines(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'App Preferences',
            icon: Icons.tune,
            color: Colors.teal,
            children: [
              _buildListTile(
                context,
                title: 'Language',
                subtitle: 'English (US)',
                icon: Icons.language,
                onTap: () => _showLanguageDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Currency',
                subtitle: 'INR (₹)',
                icon: Icons.currency_rupee,
                onTap: () => _showCurrencyDialog(context),
              ),
              _buildListTile(
                context,
                title: 'App Version',
                subtitle: 'Version 1.0.0',
                icon: Icons.info_outline,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              (user['name'] ?? 'U').toString()[0].toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
              _buildHistoryItem('Windows PC', 'New York, USA', '2 hours ago'),
              _buildHistoryItem('iPhone 14', 'New York, USA', '1 day ago'),
              _buildHistoryItem('Android Phone', 'Los Angeles, USA', '3 days ago'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String device, String location, String time) {
    return ListTile(
      leading: const Icon(Icons.devices),
      title: Text(device),
      subtitle: Text('$location • $time'),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your email within 24 hours. This includes your profile, bookings, and preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted'),
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showSavedCards(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Payment Methods'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildCardItem('Visa', '**** 4242', 'Expires 12/25'),
              _buildCardItem('Mastercard', '**** 8888', 'Expires 06/26'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Add New Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String type, String number, String expiry) {
    return ListTile(
      leading: const Icon(Icons.credit_card),
      title: Text('$type $number'),
      subtitle: Text(expiry),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {},
      ),
    );
  }

  void _showBillingAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Billing Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'PIN Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Billing address updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildTransactionItem('Booking #12345', '₹15,000', 'Feb 20, 2026', 'Success'),
              _buildTransactionItem('Booking #12344', '₹8,500', 'Feb 15, 2026', 'Success'),
              _buildTransactionItem('Booking #12343', '₹12,000', 'Feb 10, 2026', 'Refunded'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String booking, String amount, String date, String status) {
    return ListTile(
      leading: Icon(
        status == 'Success' ? Icons.check_circle : Icons.refresh,
        color: status == 'Success' ? Colors.green : Colors.orange,
      ),
      title: Text(booking),
      subtitle: Text('$date • $status'),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _showCancellationPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellation Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Free Cancellation:\n'
            '• Cancel up to 24 hours before check-in for full refund\n\n'
            'Partial Refund:\n'
            '• Cancel 12-24 hours before: 50% refund\n'
            '• Cancel 6-12 hours before: 25% refund\n\n'
            'No Refund:\n'
            '• Cancel less than 6 hours before check-in\n'
            '• No-shows are non-refundable\n\n'
            'Note: Policies may vary by hotel. Check specific hotel policy before booking.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCommunityGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Guidelines'),
        content: const SingleChildScrollView(
          child: Text(
            'Be Respectful:\n'
            '• Treat others with kindness and respect\n'
            '• No harassment, hate speech, or discrimination\n\n'
            'Honest Reviews:\n'
            '• Share genuine experiences only\n'
            '• No fake or misleading reviews\n'
            '• No promotional content\n\n'
            'Privacy:\n'
            '• Respect others\' privacy\n'
            '• Don\'t share personal information\n\n'
            'Safety:\n'
            '• Report suspicious activity\n'
            '• Follow hotel policies\n\n'
            'Violations may result in account suspension.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English (US)', true),
            _buildLanguageOption('हिंदी (Hindi)', false),
            _buildLanguageOption('தமிழ் (Tamil)', false),
            _buildLanguageOption('తెలుగు (Telugu)', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return RadioListTile<bool>(
      title: Text(language),
      value: true,
      groupValue: isSelected,
      onChanged: (val) {},
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
            _buildCurrencyOption('INR (₹)', true),
            _buildCurrencyOption('USD (\$)', false),
            _buildCurrencyOption('EUR (€)', false),
            _buildCurrencyOption('GBP (£)', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String currency, bool isSelected) {
    return RadioListTile<bool>(
      title: Text(currency),
      value: true,
      groupValue: isSelected,
      onChanged: (val) {},
    );
  }
}
