import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../theme/app_colors.dart';

/// Dashboard Tab - Main overview with stats and quick actions
class DashboardTab extends StatefulWidget {
  final Function(int) onNavigate;
  
  const DashboardTab({super.key, required this.onNavigate});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final authService = context.read<AuthService>();
    if (authService.accessToken == null) return;

    final adminService = AdminService(authService.accessToken!);
    final stats = await adminService.getDashboardStats();
    
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    _buildWelcomeCard(),
                    const SizedBox(height: 32),
                    
                    // Stats Grid
                    _buildStatsGrid(context),
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your platform with ease',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    int crossAxisCount = 2;
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth / (crossAxisCount * 130),
          children: [
            _buildStatCard(
              'Total Hotels',
              '${_stats?['total_hotels'] ?? 0}',
              Icons.hotel,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Bookings',
              '${_stats?['total_bookings'] ?? 0}',
              Icons.book,
              Colors.green,
            ),
            _buildStatCard(
              'Total Users',
              '${_stats?['total_users'] ?? 0}',
              Icons.people,
              Colors.orange,
            ),
            _buildStatCard(
              'Today\'s Bookings',
              '${_stats?['today_bookings'] ?? 0}',
              Icons.today,
              Colors.purple,
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildQuickActionButton(
          'Add New Hotel',
          'Create a new hotel listing',
          Icons.add_business,
          Colors.blue,
          () {
            widget.onNavigate(1); // Navigates to HotelsTab (index 1) index for add hotel flow
          },
        ),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          'Create Promotion',
          'Add banner, popup, or discount',
          Icons.campaign,
          Colors.orange,
          () {
            widget.onNavigate(2); // Navigates to PromotionsTab (index 2)
          },
        ),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          'Manage Prices',
          'Update hotel pricing and discounts',
          Icons.attach_money,
          Colors.green,
          () {
            widget.onNavigate(1); // Navigates to HotelsTab (index 1)
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
