import 'package:flutter/material.dart';
import 'package:lovenest/screens/admin/dashboard_tab.dart';
import 'package:lovenest/screens/admin/hotels_tab.dart';
import 'package:lovenest/screens/admin/promotions_tab.dart';
import 'package:lovenest/screens/admin/bookings_tab.dart';
import 'package:lovenest/screens/admin/users_tab.dart';
import 'package:lovenest/screens/admin/settings_tab.dart';

/// Main Admin Dashboard with Tab Navigation
/// Simple, clean interface similar to Flipkart/Amazon admin panels
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const HotelsTab(),
    const PromotionsTab(),
    const BookingsTab(),
    const UsersTab(),
    const SettingsTab(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.hotel_outlined),
      selectedIcon: Icon(Icons.hotel),
      label: 'Hotels',
    ),
    const NavigationDestination(
      icon: Icon(Icons.campaign_outlined),
      selectedIcon: Icon(Icons.campaign),
      label: 'Promotions',
    ),
    const NavigationDestination(
      icon: Icon(Icons.book_online_outlined),
      selectedIcon: Icon(Icons.book_online),
      label: 'Bookings',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Users',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
        elevation: 8,
      ),
    );
  }
}
