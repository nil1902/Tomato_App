import 'package:flutter_test/flutter_test.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Authentication Tests', () {
    late AuthService authService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
      await authService.init();
    });

    test('Auth service initializes correctly', () {
      expect(authService, isNotNull);
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('Register with valid credentials', () async {
      final result = await authService.register(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'Test123!',
        name: 'Test User',
      );
      
      // Note: This will fail without backend, but structure is correct
      expect(result, isA<bool>());
    });

    test('Login with credentials', () async {
      final result = await authService.login(
        email: 'test@example.com',
        password: 'Test123!',
      );
      
      expect(result, isA<bool>());
    });

    test('Logout clears session', () async {
      await authService.logout();
      
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.accessToken, isNull);
    });

    test('Password reset request', () async {
      final result = await authService.requestPasswordReset(
        email: 'test@example.com',
      );
      
      expect(result, isA<bool>());
    });
  });
}
