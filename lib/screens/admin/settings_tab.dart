import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Settings Tab - App Configuration
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'App Configuration',
            [
              _buildSettingTile(
                'App Name',
                'LoveNest',
                Icons.app_settings_alt,
                () => _editSetting('App Name', 'LoveNest'),
              ),
              _buildSettingTile(
                'Currency',
                'INR (₹)',
                Icons.currency_rupee,
                () => _editSetting('Currency', 'INR'),
              ),
              _buildSettingTile(
                'Default Language',
                'English',
                Icons.language,
                () => _editSetting('Language', 'English'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            'Payment Settings',
            [
              _buildSettingTile(
                'Payment Gateway',
                'Razorpay',
                Icons.payment,
                () {},
              ),
              _buildSettingTile(
                'Transaction Fee',
                '2.5%',
                Icons.percent,
                () => _editSetting('Transaction Fee', '2.5'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            'Policies',
            [
              _buildSettingTile(
                'Terms & Conditions',
                'Edit terms',
                Icons.description,
                () {},
              ),
              _buildSettingTile(
                'Privacy Policy',
                'Edit policy',
                Icons.privacy_tip,
                () {},
              ),
              _buildSettingTile(
                'Cancellation Policy',
                'Edit policy',
                Icons.cancel,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            'Notifications',
            [
              _buildSettingTile(
                'Email Notifications',
                'Enabled',
                Icons.email,
                () {},
              ),
              _buildSettingTile(
                'Push Notifications',
                'Enabled',
                Icons.notifications,
                () {},
              ),
              _buildSettingTile(
                'SMS Notifications',
                'Disabled',
                Icons.sms,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            'Database',
            [
              _buildSettingTile(
                'Backup Database',
                'Last backup: Today',
                Icons.backup,
                () => _backupDatabase(),
              ),
              _buildSettingTile(
                'Clear Cache',
                'Free up space',
                Icons.cleaning_services,
                () => _clearCache(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _editSetting(String setting, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $setting'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: setting,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$setting updated to: $result')),
        );
      }
    }
  }

  Future<void> _backupDatabase() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating backup...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database backup created successfully')),
      );
    }
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }
}
