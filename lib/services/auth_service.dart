import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'api_constants.dart';
import 'user_profile_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken; // Keep for token management
  Map<String, dynamic>? _currentUser;
  
  GoogleSignIn? _googleSignIn;
  
  AuthService() {
    // Temporarily disable Google Sign-In until properly configured
    // TODO: Configure Google OAuth Client ID in web/index.html
    _googleSignIn = null;
    debugPrint('⚠️ Google Sign-In is disabled. Configure OAuth Client ID to enable.');
  }

  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken; // For future token refresh

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    
    debugPrint('🔐 Auth Init - Token exists: ${_accessToken != null}');
    
    if (_accessToken != null) {
      await fetchCurrentUser();
      debugPrint('🔐 Auth Init - User loaded: ${_currentUser != null}');
    }
    notifyListeners();
  }

  Future<String?> register({required String email, required String password, required String name}) async {
    try {
      debugPrint('🔐 Registration attempt for: $email');
      debugPrint('🔐 API URL: ${ApiConstants.baseUrl}/api/auth/users?client_type=mobile');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/users?client_type=mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout - please check your internet connection');
        },
      );
      
      debugPrint('🔐 Registration response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = data['user'];
        
        // Create user profile in database
        if (_accessToken != null && _currentUser != null) {
          final profileService = UserProfileService(_accessToken!);
          final userId = _currentUser!['id'] ?? _currentUser!['uid'] ?? email;
          
          await profileService.createUserProfile(
            userId: userId.toString(),
            name: name,
            email: email,
          );
          
          debugPrint('🔐 User profile created for: $email');
        } else {
          // Save name temporarily for verification step
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('temp_register_name_$email', name);
        }
        
        notifyListeners();
        return null; // Success
      }
      
      String errorMsg = 'Registration failed';
      try {
        final errorData = jsonDecode(response.body);
        errorMsg = errorData['message'] ?? errorData['error'] ?? 'Registration failed';
      } catch (_) {
        errorMsg = response.body.isNotEmpty ? response.body : 'Registration failed (${response.statusCode})';
      }
      
      debugPrint('🔐 Registration Error: Status ${response.statusCode}, Msg: $errorMsg');
      return errorMsg;
    } catch (e) {
      debugPrint('🔐 Registration Exception: $e');
      debugPrint('🔐 Error Type: ${e.runtimeType}');
      
      if (e.toString().contains('SocketException')) {
        return 'Cannot connect to server. Please check:\n1. Your internet connection\n2. Firewall settings\n3. VPN if enabled';
      } else if (e.toString().contains('timeout')) {
        return 'Connection timeout. Server is taking too long to respond.';
      } else if (e.toString().contains('HandshakeException')) {
        return 'SSL/TLS error. Please check your system date/time settings.';
      }
      
      return 'Network error: ${e.toString()}';
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      debugPrint('🔐 Login attempt for: $email');
      debugPrint('🔐 API URL: ${ApiConstants.baseUrl}/api/auth/sessions?client_type=mobile');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/sessions?client_type=mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout - please check your internet connection');
        },
      );
      
      debugPrint('🔐 Login response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return 'Server returned empty response';
        }
        
        Map<String, dynamic> data;
        try {
          // Log raw response for debugging
          debugPrint('🔐 Response Content-Type: ${response.headers['content-type']}');
          debugPrint('🔐 Response body length: ${response.body.length}');
          debugPrint('🔐 First 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          debugPrint('🔐 Response bytes: ${response.bodyBytes.sublist(0, response.bodyBytes.length > 50 ? 50 : response.bodyBytes.length)}');
          debugPrint('🔐 About to decode...');
          
          // Decode the raw response body directly
          data = jsonDecode(response.body);
          
          debugPrint('🔐 Decode successful!');
          debugPrint('🔐 Data keys: ${data.keys.toList()}');
          debugPrint('🔐 Has accessToken: ${data.containsKey('accessToken')}');
          debugPrint('🔐 Has user: ${data.containsKey('user')}');
        } catch (e, stackTrace) {
          debugPrint('🔐 JSON Parse Error: $e');
          debugPrint('🔐 Stack trace: $stackTrace');
          debugPrint('🔐 Full raw response body: ${response.body}');
          debugPrint('🔐 Body char codes: ${response.body.codeUnits.take(100).toList()}');
          return 'Server returned invalid JSON format';
        }
        
        debugPrint('🔐 About to save tokens...');
        await _saveTokens(data['accessToken'], data['refreshToken']);
        debugPrint('🔐 Tokens saved!');
        
        _currentUser = data['user'];
        debugPrint('🔐 Current user set!');
        
        // 🔑 TEMPORARY: Print token for hotel data insertion
        print('═══════════════════════════════════════════════════════════════');
        print('🔑 ACCESS TOKEN FOR HOTEL INSERTION:');
        print(_accessToken);
        print('═══════════════════════════════════════════════════════════════');
        print('Copy this token and use it in scripts/insert_hotels.dart');
        print('Then remove this print statement from auth_service.dart');
        print('═══════════════════════════════════════════════════════════════');
        
        // Fetch user profile from database
        if (_accessToken != null && _currentUser != null) {
          final profileService = UserProfileService(_accessToken!);
          final userEmail = _currentUser!['email'];
          final profile = await profileService.getUserProfileByEmail(userEmail);
          
          if (profile != null) {
            // Merge profile data with current user
            _currentUser = {
              ..._currentUser!,
              'name': profile['name'],
              'phone': profile['phone'],
              'partner_name': profile['partner_name'],
              'anniversary_date': profile['anniversary_date'],
              'avatar_url': profile['avatar_url'],
              'profile_id': profile['id'],
            };
            debugPrint('🔐 User profile loaded: ${profile['name']}');
          }
        }
        
        debugPrint('🔐 Login successful - User: ${_currentUser?['email']}');
        notifyListeners();
        return null; // Success
      }
      
      String errorMsg = 'Login failed';
      try {
        final errorData = jsonDecode(response.body);
        errorMsg = errorData['message'] ?? errorData['error'] ?? 'Login failed';
      } catch (_) {
        errorMsg = response.body.isNotEmpty ? response.body : 'Login failed (${response.statusCode})';
      }
      
      debugPrint('🔐 Login failed: $errorMsg');
      return errorMsg;
    } catch (e) {
      debugPrint('🔐 Login Error: $e');
      debugPrint('🔐 Error Type: ${e.runtimeType}');
      
      if (e.toString().contains('SocketException')) {
        return 'Cannot connect to server. Please check:\n1. Your internet connection\n2. Firewall settings\n3. VPN if enabled';
      } else if (e.toString().contains('timeout')) {
        return 'Connection timeout. Server is taking too long to respond.';
      } else if (e.toString().contains('HandshakeException')) {
        return 'SSL/TLS error. Please check your system date/time settings.';
      }
      
      return 'Network error: ${e.toString()}';
    }
  }

  Future<void> fetchCurrentUser() async {
    if (_accessToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/sessions/current'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data['user'];
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Fetch User Error: $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    if (_googleSignIn == null) {
      debugPrint('🔐 Google Sign-In not available on this platform');
      return false;
    }
    
    try {
      debugPrint('🔐 Starting Google Sign-In...');
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
      
      if (googleUser == null) {
        debugPrint('🔐 Google Sign-In cancelled by user');
        return false;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        debugPrint('🔐 Failed to get Google ID token');
        return false;
      }

      debugPrint('🔐 Google Sign-In successful, authenticating with backend...');

      // Send to InsForge backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/oauth/google?client_type=mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      debugPrint('🔐 Backend response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = data['user'];
        
        // Create or fetch user profile
        if (_accessToken != null && _currentUser != null) {
          final profileService = UserProfileService(_accessToken!);
          final userEmail = _currentUser!['email'];
          final userName = _currentUser!['name'] ?? googleUser.displayName ?? 'User';
          final userId = _currentUser!['id'] ?? _currentUser!['uid'] ?? userEmail;
          
          // Try to fetch existing profile
          var profile = await profileService.getUserProfileByEmail(userEmail);
          
          if (profile == null) {
            // Create new profile
            await profileService.createUserProfile(
              userId: userId.toString(),
              name: userName,
              email: userEmail,
              avatarUrl: googleUser.photoUrl,
            );
            debugPrint('🔐 Created new profile for Google user');
          } else {
            // Merge profile data
            _currentUser = {
              ..._currentUser!,
              'name': profile['name'],
              'phone': profile['phone'],
              'partner_name': profile['partner_name'],
              'anniversary_date': profile['anniversary_date'],
              'avatar_url': profile['avatar_url'] ?? googleUser.photoUrl,
              'profile_id': profile['id'],
            };
            debugPrint('🔐 Loaded existing profile for Google user');
          }
        }
        
        debugPrint('🔐 Google authentication successful - User: ${_currentUser?['email']}');
        notifyListeners();
        return true;
      }
      
      debugPrint('🔐 Backend authentication failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('🔐 Google Sign-In Error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String partnerName,
    required DateTime anniversaryDate,
    dynamic avatarFile,
  }) async {
    if (_accessToken == null || _currentUser == null) {
      debugPrint('🔐 Update Profile Error: No access token or user');
      return false;
    }

    try {
      final profileService = UserProfileService(_accessToken!);
      final storageService = StorageService(_accessToken!);
      final userId = _currentUser!['id'] ?? _currentUser!['uid'] ?? _currentUser!['email'];
      final anniversaryDateStr = anniversaryDate.toIso8601String().split('T')[0];
      
      debugPrint('🔐 Updating profile for user: $userId');
      
      // Upload avatar if provided
      String? avatarUrl;
      if (avatarFile != null) {
        debugPrint('🔐 Uploading avatar image...');
        avatarUrl = await storageService.uploadFile(
          file: avatarFile,
          bucketName: 'avatars',
          fileName: 'avatar_$userId.${avatarFile.name.split('.').last}',
        );
        
        if (avatarUrl != null) {
          debugPrint('🔐 Avatar uploaded successfully: $avatarUrl');
        } else {
          debugPrint('🔐 Avatar upload failed, continuing without avatar update');
        }
      }
      
      // Update profile in database
      final success = await profileService.updateUserProfile(
        userId: userId.toString(),
        name: name,
        phone: phone,
        partnerName: partnerName,
        anniversaryDate: anniversaryDateStr,
        avatarUrl: avatarUrl,
      );
      
      if (success) {
        // Update local user data
        _currentUser = {
          ..._currentUser!,
          'name': name,
          'phone': phone,
          'partner_name': partnerName,
          'anniversary_date': anniversaryDateStr,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        };
        
        debugPrint('🔐 Profile updated successfully');
        notifyListeners();
        return true;
      }
      
      debugPrint('🔐 Profile update failed');
      return false;
    } catch (e) {
      debugPrint('🔐 Profile Update Error: $e');
      return false;
    }
  }

  Future<bool> requestPasswordReset({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      return false;
    }
  }

  Future<bool> verifyEmail({required String email, required String otp}) async {
    try {
      debugPrint('🔐 Verifying OTP...');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/email/verify?client_type=mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      
      debugPrint('🔐 Verify Response Status: ${response.statusCode}');
      debugPrint('🔐 Verify Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        final access = data['accessToken'] ?? data['access_token'] ?? (data['data'] != null ? data['data']['accessToken'] : null);
        final refresh = data['refreshToken'] ?? data['refresh_token'] ?? (data['data'] != null ? data['data']['refreshToken'] : null);
        final user = data['user'] ?? (data['data'] != null ? data['data']['user'] : null);
        
        await _saveTokens(access, refresh);
        _currentUser = user;
        
        // Create user profile after successful verification
        try {
          if (_accessToken != null && _currentUser != null) {
            final profileService = UserProfileService(_accessToken!);
            final userId = _currentUser!['id'] ?? _currentUser!['uid'] ?? email;
            
            final prefs = await SharedPreferences.getInstance();
            final savedName = prefs.getString('temp_register_name_$email') ?? 'User';
            
            await profileService.createUserProfile(
              userId: userId.toString(),
              name: savedName,
              email: email,
            );
            
            // Clean up temp name
            await prefs.remove('temp_register_name_$email');
          }
        } catch (profileError) {
          debugPrint('🔐 Profile Creation Error during Verification: $profileError');
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔐 Email Verification Error: $e');
      return false;
    }
  }

  Future<bool> resendVerificationEmail({required String email}) async {
    try {
      debugPrint('🔐 Resending verification email to: $email');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/email/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      debugPrint('🔐 Resend response: ${response.statusCode}');
      debugPrint('🔐 Resend body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        debugPrint('🔐 Verification email sent successfully');
        return true;
      } else {
        debugPrint('🔐 Resend failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔐 Resend Verification Error: $e');
      return false;
    }
  }

  Future<bool> loginWithOTP({required String phone, required String otp}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/otp/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = data['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('OTP Login Error: $e');
      return false;
    }
  }

  Future<bool> requestOTP({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/otp/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('OTP Request Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}/api/auth/logout'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );
      } catch (_) {}
    }
    
    // Sign out from Google
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    debugPrint('🔐 Logout successful');
    notifyListeners();
  }

  Future<void> _saveTokens(String? access, String? refresh) async {
    final prefs = await SharedPreferences.getInstance();
    if (access != null) {
      _accessToken = access;
      await prefs.setString('access_token', access);
    }
    if (refresh != null) {
      _refreshToken = refresh;
      await prefs.setString('refresh_token', refresh);
    }
  }
}
