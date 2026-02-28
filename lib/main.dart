import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_theme.dart';
import 'package:lovenest/screens/splash_screen.dart';
import 'package:lovenest/screens/login_screen.dart';
import 'package:lovenest/screens/register_screen.dart';
import 'package:lovenest/screens/home_screen.dart';
import 'package:lovenest/screens/hotel_details_screen.dart';
import 'package:lovenest/screens/booking_screen.dart';
import 'package:lovenest/screens/profile_screen.dart';
import 'package:lovenest/screens/admin/admin_main_screen.dart';
import 'package:lovenest/screens/search_screen.dart';
import 'package:lovenest/screens/bookings_list_screen.dart';
import 'package:lovenest/screens/wishlist_screen.dart';
import 'package:lovenest/screens/edit_profile_screen.dart';
import 'package:lovenest/screens/otp_login_screen.dart';
import 'package:lovenest/screens/forgot_password_screen.dart';
// import 'package:lovenest/screens/email_verification_screen.dart'; // Unused
import 'package:lovenest/screens/verify_email_screen.dart';
import 'package:lovenest/screens/notifications_screen.dart';
import 'package:lovenest/screens/coupons_screen.dart';
import 'package:lovenest/screens/loyalty_screen.dart';
import 'package:lovenest/screens/chat_list_screen.dart';
import 'package:lovenest/screens/chat_screen.dart';
import 'package:lovenest/screens/addons_screen.dart';
import 'package:lovenest/screens/account_settings_screen.dart';
import 'package:lovenest/screens/safety_centre_screen.dart';
import 'package:lovenest/screens/terms_conditions_screen.dart';
import 'package:lovenest/screens/help_support_screen.dart';
import 'package:lovenest/screens/ai_chatbot_screen.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/utils/http_client_windows.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure HTTP client for Windows
  if (Platform.isWindows) {
    HttpOverrides.global = WindowsHttpOverrides();
  }
  
  final authService = AuthService();
  
  try {
    await authService.init();
  } catch (e) {
    debugPrint('⚠️ Auth initialization error: $e');
    // Continue anyway - user can still use the app
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const LoveNestApp(),
    ),
  );
}

class LoveNestApp extends StatelessWidget {
  const LoveNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LoveNest - Couple Hotel Booking',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Supports both light/dark based on system
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp-login',
      builder: (context, state) => const OTPLoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailScreen(email: email);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingsListScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/hotel/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final imageUrl = state.extra as String?;
        return HotelDetailsScreen(hotelId: id, imageUrl: imageUrl);
      },
    ),
    GoRoute(
      path: '/book/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BookingScreen(hotelId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminMainScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/coupons',
      builder: (context, state) => const CouponsScreen(),
    ),
    GoRoute(
      path: '/loyalty',
      builder: (context, state) => const LoyaltyScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:hotelId',
      builder: (context, state) {
        final hotelId = state.pathParameters['hotelId'];
        final title = state.extra as String? ?? 'Chat';
        return ChatScreen(hotelId: hotelId, title: title);
      },
    ),
    GoRoute(
      path: '/addons',
      builder: (context, state) => const AddonsScreen(),
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/safety-centre',
      builder: (context, state) => const SafetyCentreScreen(),
    ),
    GoRoute(
      path: '/terms-conditions',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const TermsConditionsScreen(), // Can create separate privacy policy screen
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const AIChatbotScreen(),
    ),
  ],
);
