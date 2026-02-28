import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class SafetyCentreScreen extends StatelessWidget {
  const SafetyCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Centre'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.shield_outlined, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Your Safety is Our Priority',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re committed to providing a safe and secure experience for all couples',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Safety Guidelines
          _buildSection(
            context,
            title: 'Safety Guidelines',
            icon: Icons.checklist_rounded,
            color: Colors.green,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.verified_user,
                title: 'Verified Hotels',
                description: 'All hotels are verified for couple-friendly policies and safety standards',
              ),
              _buildInfoTile(
                context,
                icon: Icons.privacy_tip,
                title: 'Privacy Protection',
                description: 'Your personal information and booking details are kept confidential',
              ),
              _buildInfoTile(
                context,
                icon: Icons.security,
                title: 'Secure Payments',
                description: 'All transactions are encrypted and processed through secure payment gateways',
              ),
              _buildInfoTile(
                context,
                icon: Icons.support_agent,
                title: '24/7 Support',
                description: 'Our support team is available round the clock for any safety concerns',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Safety Tips
          _buildSection(
            context,
            title: 'Safety Tips for Couples',
            icon: Icons.lightbulb_outline,
            color: Colors.orange,
            children: [
              _buildTipTile(
                context,
                number: '1',
                title: 'Verify Hotel Details',
                description: 'Always check hotel reviews, ratings, and couple-friendly policies before booking',
              ),
              _buildTipTile(
                context,
                number: '2',
                title: 'Keep Documents Ready',
                description: 'Carry valid ID proofs and booking confirmation for smooth check-in',
              ),
              _buildTipTile(
                context,
                number: '3',
                title: 'Share Your Plans',
                description: 'Inform a trusted friend or family member about your travel plans',
              ),
              _buildTipTile(
                context,
                number: '4',
                title: 'Check Safety Features',
                description: 'Ensure your room has working locks, emergency exits, and safety equipment',
              ),
              _buildTipTile(
                context,
                number: '5',
                title: 'Trust Your Instincts',
                description: 'If something feels wrong, contact hotel management or our support team immediately',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Emergency Contacts
          _buildSection(
            context,
            title: 'Emergency Contacts',
            icon: Icons.phone_in_talk,
            color: Colors.red,
            children: [
              _buildContactTile(
                context,
                icon: Icons.headset_mic,
                title: 'LoveNest Support',
                contact: '+91-1800-123-4567',
                description: 'Available 24/7 for any concerns',
                onTap: () => _showCallDialog(context, 'LoveNest Support', '+91-1800-123-4567'),
              ),
              _buildContactTile(
                context,
                icon: Icons.local_police,
                title: 'Police Emergency',
                contact: '100',
                description: 'For immediate police assistance',
                onTap: () => _showCallDialog(context, 'Police Emergency', '100'),
              ),
              _buildContactTile(
                context,
                icon: Icons.local_hospital,
                title: 'Medical Emergency',
                contact: '108',
                description: 'For ambulance and medical help',
                onTap: () => _showCallDialog(context, 'Medical Emergency', '108'),
              ),
              _buildContactTile(
                context,
                icon: Icons.support,
                title: 'Women Helpline',
                contact: '1091',
                description: 'For women in distress',
                onTap: () => _showCallDialog(context, 'Women Helpline', '1091'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Report Issues
          _buildSection(
            context,
            title: 'Report Safety Concerns',
            icon: Icons.report_problem_outlined,
            color: Colors.blue,
            children: [
              _buildActionTile(
                context,
                icon: Icons.flag,
                title: 'Report a Hotel',
                description: 'Report safety issues or policy violations',
                onTap: () => _showReportDialog(context, 'Report Hotel'),
              ),
              _buildActionTile(
                context,
                icon: Icons.feedback,
                title: 'Safety Feedback',
                description: 'Share your safety experience with us',
                onTap: () => _showReportDialog(context, 'Safety Feedback'),
              ),
              _buildActionTile(
                context,
                icon: Icons.block,
                title: 'Block & Report User',
                description: 'Report inappropriate behavior',
                onTap: () => _showReportDialog(context, 'Report User'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Additional Resources
          _buildSection(
            context,
            title: 'Additional Resources',
            icon: Icons.menu_book,
            color: AppColors.accent1,
            children: [
              _buildLinkTile(
                context,
                icon: Icons.article,
                title: 'Safety Guidelines PDF',
                description: 'Download comprehensive safety guide',
                onTap: () {},
              ),
              _buildLinkTile(
                context,
                icon: Icons.video_library,
                title: 'Safety Videos',
                description: 'Watch safety tips and tutorials',
                onTap: () {},
              ),
              _buildLinkTile(
                context,
                icon: Icons.question_answer,
                title: 'Safety FAQs',
                description: 'Common safety questions answered',
                onTap: () => context.push('/help-support'),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: theme.textTheme.bodySmall),
    );
  }

  Widget _buildTipTile(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accent2.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.accent2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: theme.textTheme.bodySmall),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String contact,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: Colors.red, size: 28),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: Colors.green),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
    );
  }

  void _showCallDialog(BuildContext context, String service, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $service'),
        content: Text('Do you want to call $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $number...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, String type) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Describe the issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
                const SnackBar(content: Text('Report submitted. Our team will review it shortly.')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
