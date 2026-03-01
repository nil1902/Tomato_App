import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Premium SaaS Dashboard Tab
class DashboardTab extends StatefulWidget {
  final Function(int) onNavigate;
  
  const DashboardTab({super.key, required this.onNavigate});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  // Premium Theme Colors
  final Color primaryColor = const Color(0xFFFF385C); // Burgundy/Rose
  final Color primaryLight = const Color(0xFFFFF0F2);
  final Color textDark = const Color(0xFF1E1E2C);
  final Color textMuted = const Color(0xFF8A8A9E);
  final Color bgLight = const Color(0xFFF7F7FA);

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
    
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track your property portfolio and bookings',
                              style: TextStyle(fontSize: 14, color: textMuted),
                            ),
                          ],
                        ),
                        // Date picker / Filter Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: textMuted),
                              const SizedBox(width: 8),
                              Text('Last 30 Days', style: TextStyle(color: textDark, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, size: 18, color: textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // KPI Cards
                    _buildKPIGrid(context),
                    const SizedBox(height: 32),

                    // Main Content Split (Charts & Activity)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isDesktop = constraints.maxWidth > 800;
                        return isDesktop 
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildRevenueChart()),
                                const SizedBox(width: 24),
                                Expanded(flex: 1, child: _buildActivityFeed()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildRevenueChart(),
                                const SizedBox(height: 24),
                                _buildActivityFeed(),
                              ],
                            );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.8,
          children: [
            _buildPremiumStatCard('Total Revenue', '₹2,45,000', '+12.5%', Icons.account_balance_wallet, const Color(0xFF10B981)), // Green
            _buildPremiumStatCard('Total Bookings', '${_stats?['total_bookings'] ?? 142}', '+8.2%', Icons.book_online, const Color(0xFF3B82F6)), // Blue
            _buildPremiumStatCard('Active Hotels', '${_stats?['total_hotels'] ?? 0}', '0.0%', Icons.apartment, const Color(0xFF8B5CF6)), // Purple
            _buildPremiumStatCard('Conversion Rate', '4.8%', '+1.2%', Icons.show_chart, const Color(0xFFF59E0B)), // Orange
          ],
        );
      }
    );
  }

  Widget _buildPremiumStatCard(String title, String value, String trend, IconData icon, Color iconColor) {
    bool isPositive = trend.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, 
                         size: 12, color: isPositive ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 8),
          Text('Monthly revenue break down', style: TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 40),
          // Mock Bar Chart
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Jan', 0.4),
                _buildBar('Feb', 0.6),
                _buildBar('Mar', 0.5),
                _buildBar('Apr', 0.8),
                _buildBar('May', 0.7),
                _buildBar('Jun', 0.9, isHighlight: true),
                _buildBar('Jul', 0.6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightRatio, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 32,
          height: 200 * heightRatio, // Max height is 200
          decoration: BoxDecoration(
            color: isHighlight ? primaryColor : primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem('New Booking', 'Taj Palace, Mumbai', '2 mins ago', Icons.book_online, const Color(0xFF3B82F6)),
                _buildActivityItem('New User', 'Rahul Sharma registered', '15 mins ago', Icons.person_add, const Color(0xFF10B981)),
                _buildActivityItem('Review Added', '5 stars for Oberoi', '1 hour ago', Icons.star, const Color(0xFFF59E0B)),
                _buildActivityItem('Payment Failed', 'Booking #1024', '3 hours ago', Icons.error_outline, const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildActionButton('Add Hotel', Icons.add_business, () => widget.onNavigate(1))),
          if (!isMobile) const SizedBox(width: 16),
          Expanded(child: _buildActionButton('Add Coupon', Icons.local_offer, () => widget.onNavigate(2))),
          if (!isMobile) const SizedBox(width: 16),
          Expanded(child: _buildActionButton('View Bookings', Icons.calendar_month, () => widget.onNavigate(3))),
          if (!isMobile) const SizedBox(width: 16),
          Expanded(child: _buildActionButton('Support', Icons.headset_mic, () {})),
        ],
      );
    });
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ]
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
