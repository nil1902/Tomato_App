import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Creating Admin User...\n');
  
  // Admin credentials
  const String adminEmail = 'admin@lovenest.com';
  const String adminPassword = 'LoveNest@Admin2024!';
  const String adminName = 'System Administrator';
  
  print('Admin Credentials:');
  print('Email: $adminEmail');
  print('Password: $adminPassword');
  print('\n⚠️  SAVE THESE CREDENTIALS SECURELY!\n');
  
  try {
    // Step 1: Register admin user
    print('Step 1: Registering admin user...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': adminEmail,
        'password': adminPassword,
        'name': adminName,
      }),
    );
    
    print('Registration Status: ${registerResponse.statusCode}');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      final registerData = jsonDecode(registerResponse.body);
      print('✅ Admin user registered successfully');
      
      // Check if we got tokens immediately or need verification
      if (registerData['accessToken'] != null) {
        final accessToken = registerData['accessToken'];
        final userId = registerData['user']['id'] ?? registerData['user']['uid'];
        
        print('✅ Got access token immediately');
        await _createAdminProfile(accessToken, userId, adminName, adminEmail);
      } else {
        print('⚠️  Email verification may be required');
        print('Check your email for verification code');
      }
    } else {
      print('Response: ${registerResponse.body}');
      
      // If user already exists, try to login
      if (registerResponse.body.contains('already exists') || 
          registerResponse.body.contains('duplicate') ||
          registerResponse.statusCode == 409) {
        print('\n⚠️  Admin user already exists. Attempting login...');
        await _loginAdmin(adminEmail, adminPassword, adminName);
      }
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}

Future<void> _loginAdmin(String email, String password, String name) async {
  try {
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/sessions?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    print('Login Status: ${loginResponse.statusCode}');
    
    if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
      final loginData = jsonDecode(loginResponse.body);
      final accessToken = loginData['accessToken'];
      final userId = loginData['user']['id'] ?? loginData['user']['uid'];
      
      print('✅ Login successful');
      await _createAdminProfile(accessToken, userId, name, email);
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
}

Future<void> _createAdminProfile(String accessToken, String userId, String name, String email) async {
  try {
    print('\nCreating admin profile...');
    
    // Check if profile already exists
    final checkResponse = await http.get(
      Uri.parse('$baseUrl/api/database/records/user_profiles?user_id=eq.$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (checkResponse.statusCode == 200) {
      final profiles = jsonDecode(checkResponse.body);
      if (profiles.isNotEmpty) {
        // Update existing profile to admin
        print('Profile exists, updating to admin role...');
        final profileId = profiles[0]['id'];
        
        final updateResponse = await http.patch(
          Uri.parse('$baseUrl/api/database/records/user_profiles?id=eq.$profileId'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          body: jsonEncode({
            'role': 'admin',
          }),
        );
        
        if (updateResponse.statusCode == 200 || updateResponse.statusCode == 204) {
          print('✅ Profile updated to admin role');
          _printSuccess(email, 'LoveNest@Admin2024!');
        } else {
          print('⚠️  Update response: ${updateResponse.statusCode}');
          print('Response: ${updateResponse.body}');
        }
        return;
      }
    }
    
    // Create new profile
    final profileResponse = await http.post(
      Uri.parse('$baseUrl/api/database/records/user_profiles'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: jsonEncode([{
        'user_id': userId,
        'name': name,
        'email': email,
        'role': 'admin',
      }]),
    );
    
    if (profileResponse.statusCode == 200 || profileResponse.statusCode == 201) {
      print('✅ Admin profile created successfully');
      _printSuccess(email, 'LoveNest@Admin2024!');
    } else {
      print('⚠️  Profile creation response: ${profileResponse.statusCode}');
      print('Response: ${profileResponse.body}');
    }
  } catch (e) {
    print('❌ Profile creation error: $e');
  }
}

void _printSuccess(String email, String password) {
  print('\n' + '='*60);
  print('🎉 ADMIN ACCOUNT READY!');
  print('='*60);
  print('\n📧 Login Credentials:');
  print('   Email: $email');
  print('   Password: $password');
  print('\n🔐 Access Level: FULL ADMIN');
  print('   - Manage all hotels');
  print('   - View all bookings');
  print('   - Manage users');
  print('   - Full database access');
  print('\n⚠️  IMPORTANT: Store these credentials securely!');
  print('='*60);
}
