import 'package:flutter/material.dart';
import 'package:lovenest/screens/admin/dashboard_tab.dart';
import 'package:lovenest/screens/admin/hotels_tab.dart';
import 'package:lovenest/screens/admin/promotions_tab.dart';
import 'package:lovenest/screens/admin/bookings_tab.dart';
import 'package:lovenest/screens/admin/users_tab.dart';
import 'package:lovenest/screens/admin/settings_tab.dart';
import 'package:lovenest/screens/admin/reviews_tab.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:go_router/go_router.dart';

/// Main Admin Dashboard with Responsive Navigation & Premium SaaS UI
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  bool _isExtended = true;

  // Premium Theme Colors
  final Color primaryColor = const Color(0xFFFF385C); // Burgundy/Rose
  final Color primaryLight = const Color(0xFFFFF0F2); // Soft Pink
  final Color bgLight = const Color(0xFFF7F7FA);
  final Color textDark = const Color(0xFF1E1E2C);
  final Color textMuted = const Color(0xFF8A8A9E);

  late final List<Widget> _tabs = [
    DashboardTab(onNavigate: (index) {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }),
    const HotelsTab(),
    const PromotionsTab(),
    const BookingsTab(),
    const ReviewsTab(),
    const UsersTab(),
    const SettingsTab(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Hotels Management',
    'Promotions & Coupons',
    'Bookings Management',
    'Reviews Management',
    'Users Management',
    'System Settings',
  ];

  late final List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: primaryColor),
      label: const Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.hotel_outlined),
      selectedIcon: Icon(Icons.hotel, color: primaryColor),
      label: const Text('Hotels'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.campaign_outlined),
      selectedIcon: Icon(Icons.campaign, color: primaryColor),
      label: const Text('Promotions'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.book_online_outlined),
      selectedIcon: Icon(Icons.book_online, color: primaryColor),
      label: const Text('Bookings'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.rate_review_outlined),
      selectedIcon: Icon(Icons.rate_review, color: primaryColor),
      label: const Text('Reviews'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people, color: primaryColor),
      label: const Text('Users'),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings, color: primaryColor),
      label: const Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: _isExtended && !isMobile ? 250 : 70,
            leading: Row(
              children: [
                if (isMobile)
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: textDark),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(_isExtended ? Icons.menu_open : Icons.menu, color: textDark),
                    onPressed: () {
                      setState(() {
                        _isExtended = !_isExtended;
                      });
                    },
                  ),
                if (!isMobile && _isExtended) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.spa, color: primaryColor, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'LoveNest',
                    style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
                  ),
                ]
              ],
            ),
            title: Text(
              _titles[_selectedIndex],
              style: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
            ),
            actions: [
              // Global Search (Glassmorphism inspired)
              if (!isMobile)
                Container(
                  width: 280,
                  height: 42,
                  margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.03)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search anywhere...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search, size: 18, color: textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              // Notifications
              Center(
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_none_rounded, color: textDark, size: 26),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Profile
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await AuthService().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryLight, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin+User&background=FF385C&color=fff'),
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('admin@lovenest.com', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20),
                          SizedBox(width: 12),
                          Text('Account Settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Text('Sign Out', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: primaryColor),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.spa, size: 36, color: Color(0xFFFF385C)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'LoveNest Admin',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0; i < _railDestinations.length; i++)
                    ListTile(
                      leading: _selectedIndex == i ? _railDestinations[i].selectedIcon : _railDestinations[i].icon,
                      title: _railDestinations[i].label,
                      selected: _selectedIndex == i,
                      selectedColor: primaryColor,
                      selectedTileColor: primaryLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: NavigationRail(
                elevation: 1, // Satisfies assertion: elevation == null || elevation > 0
                extended: isDesktop && _isExtended,
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: _railDestinations,
                indicatorColor: primaryLight,
                selectedIconTheme: IconThemeData(color: primaryColor),
                unselectedIconTheme: IconThemeData(color: textMuted),
                selectedLabelTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                unselectedLabelTextStyle: TextStyle(color: textMuted, fontWeight: FontWeight.w500, letterSpacing: -0.2),
                minExtendedWidth: 250,
                groupAlignment: -0.9,
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _tabs[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
