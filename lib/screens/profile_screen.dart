import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = context.watch<AuthService>().currentUser;
    final userName = currentUser?['name'] ?? 'Guest User';
    final userEmail = currentUser?['email'] ?? 'guest@lovenest.com';
    final avatarUrl = currentUser?['avatar_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Head Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_image',
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Icon(Icons.person, size: 40, color: AppColors.primary),
                                errorWidget: (context, url, error) => const Icon(Icons.person, size: 40, color: AppColors.primary),
                              )
                            : const Icon(Icons.person, size: 40, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(userEmail, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                     icon: const Icon(Icons.edit, color: AppColors.primary),
                     onPressed: () {
                       context.push('/profile/edit');
                     },
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings List
            _buildSectionHeader(context, 'Account Settings'),
            _buildListTile(context, title: 'Account & Privacy', icon: Icons.settings, color: AppColors.primary, onTap: () => context.push('/account-settings')),
            _buildListTile(context, title: 'Booking History', icon: Icons.history, color: AppColors.accent1, onTap: () => context.push('/bookings')),
            _buildListTile(context, title: 'Saved Nests (Favorites)', icon: Icons.favorite_border, color: AppColors.primary, onTap: () => context.push('/wishlist')),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Rewards & Offers'),
            _buildListTile(context, title: 'Loyalty Points', icon: Icons.card_giftcard, color: Colors.amber, onTap: () => context.push('/loyalty')),
            _buildListTile(context, title: 'Coupons & Offers', icon: Icons.local_offer, color: Colors.green, onTap: () => context.push('/coupons')),
            _buildListTile(context, title: 'Romantic Add-ons', icon: Icons.favorite, color: Colors.pink, onTap: () => context.push('/addons')),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Communication'),
            _buildListTile(context, title: 'Messages & Chat', icon: Icons.chat_bubble_outline, color: Colors.blue, onTap: () => context.push('/chat')),
            _buildListTile(context, title: 'Notifications', icon: Icons.notifications_outlined, color: Colors.orange, onTap: () => context.push('/notifications')),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Support & Info'),
            _buildListTile(context, title: 'AI Assistant', icon: Icons.smart_toy, color: Colors.blue, onTap: () => context.push('/ai-assistant')),
            _buildListTile(context, title: 'Help & Support', icon: Icons.help_outline, color: AppColors.accent2, onTap: () => context.push('/help-support')),
            _buildListTile(context, title: 'Safety Center', icon: Icons.shield_outlined, color: Colors.green),
            _buildListTile(context, title: 'Terms & Conditions', icon: Icons.description_outlined, color: AppColors.textSecondary),

            const SizedBox(height: 48),
            // Logout
             SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text('Log Out', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
             context.push('/home');
          } else if (index == 1) {
             context.push('/search');
          } else if (index == 2) {
             context.push('/bookings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Nests'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required String title, required IconData icon, required Color color, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap ?? () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
