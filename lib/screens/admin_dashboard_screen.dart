import 'package:flutter/material.dart';
import 'package:lovenest/screens/admin/admin_main_screen.dart';

/// Admin Dashboard Screen - Entry point for admin panel
/// Redirects to the new AdminMainScreen with tab navigation
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply return the new admin main screen with tabs
    return const AdminMainScreen();
  }
}
