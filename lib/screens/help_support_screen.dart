import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFD4145A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💬 Need Help?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'re here to make your experience perfect',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.chat_bubble,
                        label: 'Chat',
                        onTap: () => context.push('/chat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.phone,
                        label: 'Call',
                        onTap: () => _makePhoneCall('1-800-LOVE-NEST'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Section
          _buildSection(
            context,
            title: 'Frequently Asked Questions',
            icon: Icons.help_outline,
            color: Colors.blue,
            children: [
              _buildFAQItem(
                context,
                question: 'How do I make a booking?',
                answer: 'Browse our romantic hotels, select your dates, choose your room, and complete the payment. You\'ll receive instant confirmation via email.',
              ),
              _buildFAQItem(
                context,
                question: 'What is the cancellation policy?',
                answer: 'Free cancellation up to 24 hours before check-in. After that, a cancellation fee may apply depending on the hotel policy.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I earn loyalty points?',
                answer: 'Earn 1 point for every \$1 spent on bookings. 100 points = \$1 discount. Plus, get bonus points for reviews and referrals!',
              ),
              _buildFAQItem(
                context,
                question: 'Can I modify my booking?',
                answer: 'Yes! Go to My Bookings, select your reservation, and tap "Modify Booking". Changes are subject to availability.',
              ),
              _buildFAQItem(
                context,
                question: 'Are the romantic add-ons included?',
                answer: 'Add-ons like rose petals, champagne, and spa packages are optional extras. You can add them during booking or later.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Options
          _buildSection(
            context,
            title: 'Contact Us',
            icon: Icons.contact_support,
            color: Colors.green,
            children: [
              _buildContactTile(
                context,
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@lovenest.com',
                onTap: () => _sendEmail('support@lovenest.com'),
              ),
              _buildContactTile(
                context,
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '1-800-LOVE-NEST (24/7)',
                onTap: () => _makePhoneCall('1-800-LOVE-NEST'),
              ),
              _buildContactTile(
                context,
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => context.push('/chat'),
              ),
              _buildContactTile(
                context,
                icon: Icons.location_on,
                title: 'Visit Us',
                subtitle: '123 Romance Street, Love City, LC 12345',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resources
          _buildSection(
            context,
            title: 'Resources',
            icon: Icons.library_books,
            color: Colors.orange,
            children: [
              _buildResourceTile(
                context,
                icon: Icons.article,
                title: 'Booking Guide',
                subtitle: 'Learn how to book the perfect stay',
                onTap: () => _showBookingGuide(context),
              ),
              _buildResourceTile(
                context,
                icon: Icons.security,
                title: 'Safety Guidelines',
                subtitle: 'Your safety is our priority',
                onTap: () => _showSafetyGuidelines(context),
              ),
              _buildResourceTile(
                context,
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: 'Accepted payment options',
                onTap: () => _showPaymentInfo(context),
              ),
              _buildResourceTile(
                context,
                icon: Icons.card_giftcard,
                title: 'Gift Cards',
                subtitle: 'Give the gift of romance',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Feedback
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                const Icon(Icons.feedback, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Share Your Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us improve your experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showFeedbackDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Send Feedback'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildResourceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showBookingGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Guide'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Browse Hotels: Explore our curated collection of romantic hotels\n\n'
            '2. Select Dates: Choose your check-in and check-out dates\n\n'
            '3. Choose Room: Pick the perfect room for your stay\n\n'
            '4. Add Extras: Enhance your experience with romantic add-ons\n\n'
            '5. Complete Payment: Secure your booking with instant confirmation\n\n'
            '6. Enjoy: Receive your booking details and prepare for romance!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSafetyGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Guidelines'),
        content: const SingleChildScrollView(
          child: Text(
            '• All hotels are verified and meet our safety standards\n\n'
            '• 24/7 customer support available\n\n'
            '• Secure payment processing with encryption\n\n'
            '• Privacy protection for all bookings\n\n'
            '• Emergency contact information provided\n\n'
            '• COVID-19 safety protocols in place\n\n'
            '• Regular health and safety inspections',
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

  void _showPaymentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('We accept:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('• Visa, Mastercard, American Express'),
              Text('• Debit Cards'),
              Text('• PayPal'),
              Text('• Apple Pay & Google Pay'),
              Text('• Bank Transfers'),
              SizedBox(height: 16),
              Text('All payments are secure and encrypted.'),
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

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
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
                  content: Text('Thank you for your feedback!'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
