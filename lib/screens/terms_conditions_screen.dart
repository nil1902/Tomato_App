import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                Row(
                  children: [
                    Icon(Icons.description, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: February 28, 2026',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please read these terms and conditions carefully before using LoveNest services.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            context,
            title: '1. Acceptance of Terms',
            content: 'By accessing and using LoveNest ("the Service"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these terms, please do not use our Service.\n\nThese terms apply to all users of the Service, including without limitation users who are browsers, customers, merchants, and/or contributors of content.',
          ),

          _buildSection(
            context,
            title: '2. Service Description',
            content: 'LoveNest is a platform that connects couples with romantic, couple-friendly hotels and accommodations. We provide:\n\n• Hotel search and booking services\n• Verified couple-friendly accommodations\n• Secure payment processing\n• Customer support and assistance\n• Personalized recommendations\n\nWe reserve the right to modify, suspend, or discontinue any part of the Service at any time.',
          ),

          _buildSection(
            context,
            title: '3. User Accounts',
            content: 'To use certain features of the Service, you must register for an account. You agree to:\n\n• Provide accurate, current, and complete information\n• Maintain and update your information\n• Keep your password secure and confidential\n• Accept responsibility for all activities under your account\n• Notify us immediately of any unauthorized use\n\nYou must be at least 18 years old to create an account and use our Service.',
          ),

          _buildSection(
            context,
            title: '4. Booking and Payments',
            content: 'When you make a booking through LoveNest:\n\n• You agree to pay all charges at the prices in effect when incurred\n• All payments are processed securely through our payment partners\n• Prices are subject to change without notice\n• You are responsible for any applicable taxes\n• Cancellation policies vary by hotel and are clearly stated\n• Refunds are subject to the hotel\'s cancellation policy\n\nWe act as an intermediary between you and the hotel. The hotel is responsible for providing the accommodation services.',
          ),

          _buildSection(
            context,
            title: '5. Cancellation Policy',
            content: 'Cancellation policies vary by property and are clearly displayed during booking:\n\n• Free cancellation may be available for certain bookings\n• Cancellation fees may apply based on timing\n• No-shows may result in full charges\n• Refunds are processed according to hotel policy\n• Processing time for refunds: 5-10 business days\n\nPlease review the specific cancellation policy before confirming your booking.',
          ),

          _buildSection(
            context,
            title: '6. User Conduct',
            content: 'You agree not to:\n\n• Violate any laws or regulations\n• Infringe on intellectual property rights\n• Transmit harmful or malicious code\n• Harass, abuse, or harm others\n• Provide false or misleading information\n• Use the Service for unauthorized commercial purposes\n• Attempt to gain unauthorized access to our systems\n• Interfere with the proper functioning of the Service\n\nViolation of these terms may result in account suspension or termination.',
          ),

          _buildSection(
            context,
            title: '7. Privacy and Data Protection',
            content: 'Your privacy is important to us. We collect and use your personal information as described in our Privacy Policy:\n\n• We collect information you provide and usage data\n• We use data to provide and improve our Service\n• We protect your data with industry-standard security\n• We do not sell your personal information\n• You have rights to access, correct, and delete your data\n\nPlease review our Privacy Policy for complete details.',
          ),

          _buildSection(
            context,
            title: '8. Intellectual Property',
            content: 'All content on LoveNest, including text, graphics, logos, images, and software, is the property of LoveNest or its licensors and is protected by copyright and trademark laws.\n\nYou may not:\n• Copy, modify, or distribute our content\n• Use our trademarks without permission\n• Reverse engineer our software\n• Create derivative works\n\nUser-generated content (reviews, photos) remains your property, but you grant us a license to use it.',
          ),

          _buildSection(
            context,
            title: '9. Reviews and Ratings',
            content: 'When you submit reviews or ratings:\n\n• Content must be honest and based on your experience\n• No offensive, defamatory, or inappropriate content\n• No promotional or commercial content\n• We reserve the right to remove or edit reviews\n• Reviews must comply with our community guidelines\n\nFalse or misleading reviews may result in account termination.',
          ),

          _buildSection(
            context,
            title: '10. Limitation of Liability',
            content: 'LoveNest acts as an intermediary and is not responsible for:\n\n• The quality or condition of hotel accommodations\n• Actions or omissions of hotel staff\n• Injuries, losses, or damages during your stay\n• Force majeure events (natural disasters, etc.)\n• Third-party services or content\n\nOur total liability is limited to the amount you paid for the booking. We are not liable for indirect, incidental, or consequential damages.',
          ),

          _buildSection(
            context,
            title: '11. Indemnification',
            content: 'You agree to indemnify and hold harmless LoveNest, its affiliates, officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including legal fees) arising from:\n\n• Your use of the Service\n• Your violation of these terms\n• Your violation of any rights of others\n• Your conduct in connection with the Service',
          ),

          _buildSection(
            context,
            title: '12. Dispute Resolution',
            content: 'In the event of any dispute:\n\n• First, contact our customer support for resolution\n• If unresolved, disputes will be settled through arbitration\n• Arbitration will be conducted in accordance with applicable laws\n• You waive the right to participate in class actions\n• Governing law: Laws of India\n• Jurisdiction: Courts of [Your City], India',
          ),

          _buildSection(
            context,
            title: '13. Modifications to Terms',
            content: 'We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting. Your continued use of the Service after changes constitutes acceptance of the modified terms.\n\nWe will notify you of significant changes via email or through the Service.',
          ),

          _buildSection(
            context,
            title: '14. Termination',
            content: 'We may terminate or suspend your account and access to the Service:\n\n• For violation of these terms\n• For fraudulent or illegal activity\n• At our sole discretion with or without notice\n• Upon your request to delete your account\n\nUpon termination, your right to use the Service ceases immediately. Provisions that should survive termination will remain in effect.',
          ),

          _buildSection(
            context,
            title: '15. Contact Information',
            content: 'For questions about these Terms & Conditions, please contact us:\n\nLoveNest Support Team\nEmail: legal@lovenest.com\nPhone: +91-1800-123-4567\nAddress: [Your Business Address]\n\nCustomer Support Hours:\nMonday - Sunday: 24/7',
          ),

          const SizedBox(height: 24),

          // Agreement Checkbox (for reference)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By using LoveNest, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
