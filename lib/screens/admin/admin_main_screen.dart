import 'package:flutter/material.dart';
import 'package:lovenest/screens/admin/dashboard_tab.dart';
import 'package:lovenest/screens/admin/hotels_tab.dart';
import 'package:lovenest/screens/admin/promotions_tab.dart';
import 'package:lovenest/screens/admin/bookings_tab.dart';
import 'package:lovenest/screens/admin/users_tab.dart';
import 'package:lovenest/screens/admin/settings_tab.dart';
import 'package:lovenest/screens/admin/reviews_tab.dart';

/// Main Admin Dashboard with Responsive Navigation (Sidebar / Drawer)
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  bool _isExtended = true;

  late final List<Widget> _tabs = [
    DashboardTab(onNavigate: (index) {
      setState(() {
        _selectedIndex = index;
      });
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

  final List<NavigationRailDestination> _railDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: Colors.blueAccent),
      label: Text('Dashboard'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.hotel_outlined),
      selectedIcon: Icon(Icons.hotel, color: Colors.blueAccent),
      label: Text('Hotels'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.campaign_outlined),
      selectedIcon: Icon(Icons.campaign, color: Colors.blueAccent),
      label: Text('Promotions'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.book_online_outlined),
      selectedIcon: Icon(Icons.book_online, color: Colors.blueAccent),
      label: Text('Bookings'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.rate_review_outlined),
      selectedIcon: Icon(Icons.rate_review, color: Colors.blueAccent),
      label: Text('Reviews'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people, color: Colors.blueAccent),
      label: Text('Users'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings, color: Colors.blueAccent),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final bool isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: Icon(_isExtended ? Icons.menu_open : Icons.menu, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _isExtended = !_isExtended;
                  });
                },
              ),
        title: Row(
          children: [
            if (!isMobile) ...[
              const Icon(Icons.admin_panel_settings, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 8),
              const Text(
                'LoveNest Admin',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(width: 24),
            ],
            // Breadcrumb or Page Title
            Text(
              _titles[_selectedIndex],
              style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Global Search
          if (!isMobile)
            Container(
              width: 250,
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search anywhere...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          // Notifications
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined, color: Colors.black87),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          // Profile
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin+User&background=0D8ABC&color=fff'),
            ),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blueAccent),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blueAccent),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'LoveNest Admin',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0; i < _railDestinations.length; i++)
                    ListTile(
                      leading: _selectedIndex == i
                          ? _railDestinations[i].selectedIcon
                          : _railDestinations[i].icon,
                      title: _railDestinations[i].label,
                      selected: _selectedIndex == i,
                      selectedColor: Colors.blueAccent,
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
            NavigationRail(
              extended: isDesktop && _isExtended,
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _railDestinations,
              selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
              selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
              unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
              elevation: 2,
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tabs[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
