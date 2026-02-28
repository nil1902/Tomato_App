import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Creating Admin Account for Nilimesh...\n');
  
  // Your admin credentials
  const String adminEmail = 'nilimeshpal15@gmail.com';
  const String adminPassword = 'Nilimesh@2002';
  const String adminName = 'Nilimesh Pal';
  
  print('Admin Credentials:');
  print('Email: $adminEmail');
  print('Password: $adminPassword');
  print('Name: $adminName');
  print('\n');
  
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
        print('\n📧 EMAIL VERIFICATION REQUIRED');
        print('═══════════════════════════════════════════════════════════════');
        print('Check your email: $adminEmail');
        print('Enter the verification code in the app to complete setup');
        print('After verification, your account will have admin access');
        print('═══════════════════════════════════════════════════════════════');
      }
    } else {
      final responseBody = registerResponse.body;
      print('Response: $responseBody');
      
      // If user already exists, try to login and set admin role
      if (responseBody.contains('already exists') || 
          responseBody.contains('duplicate') ||
          registerResponse.statusCode == 409 ||
          responseBody.contains('User already registered')) {
        print('\n⚠️  Account already exists. Attempting to set admin role...');
        await _loginAndSetAdmin(adminEmail, adminPassword, adminName);
      }
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}

Future<void> _loginAndSetAdmin(String email, String password, String name) async {
  try {
    print('\nAttempting login...');
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
      print('\n⚠️  If your account exists but login failed:');
      print('1. Verify your email first if you haven\'t already');
      print('2. Make sure password is correct: $password');
      print('3. Try logging in through the app');
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
}

Future<void> _createAdminProfile(String accessToken, String userId, String name, String email) async {
  try {
    print('\nSetting up admin profile...');
    
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
          _printSuccess(email, 'Nilimesh@2002');
        } else {
          print('⚠️  Update response: ${updateResponse.statusCode}');
          print('Response: ${updateResponse.body}');
          
          // Try alternative approach - check if role column exists
          print('\nTrying to add role column to profile...');
          _printManualInstructions(email);
        }
        return;
      }
    }
    
    // Create new profile with admin role
    print('Creating new admin profile...');
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
      _printSuccess(email, 'Nilimesh@2002');
    } else {
      print('⚠️  Profile creation response: ${profileResponse.statusCode}');
      print('Response: ${profileResponse.body}');
      _printManualInstructions(email);
    }
  } catch (e) {
    print('❌ Profile setup error: $e');
    _printManualInstructions(email);
  }
}

void _printSuccess(String email, String password) {
  print('\n' + '='*70);
  print('🎉 ADMIN ACCOUNT READY!');
  print('='*70);
  print('\n📧 Your Admin Login:');
  print('   Email: $email');
  print('   Password: $password');
  print('\n🔐 Access Level: FULL ADMIN');
  print('   ✓ Manage all hotels (add, edit, delete)');
  print('   ✓ View and manage all bookings');
  print('   ✓ Manage user accounts');
  print('   ✓ Access analytics dashboard');
  print('   ✓ Full database access');
  print('\n📱 Next Steps:');
  print('   1. Open your LoveNest app');
  print('   2. Login with the credentials above');
  print('   3. Go to Settings → Admin Panel');
  print('   4. Start managing your platform!');
  print('\n⚠️  IMPORTANT: Keep these credentials secure!');
  print('='*70);
}

void _printManualInstructions(String email) {
  print('\n' + '='*70);
  print('⚠️  MANUAL SETUP REQUIRED');
  print('='*70);
  print('\nYour account exists but needs admin role assignment.');
  print('\nOption 1: Add role column to database (if missing)');
  print('Run this SQL in your InsForge database:');
  print('');
  print('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT \'user\';');
  print('UPDATE user_profiles SET role = \'admin\' WHERE email = \'$email\';');
  print('');
  print('\nOption 2: Use existing account');
  print('If the role column exists, just login with:');
  print('Email: $email');
  print('Password: Nilimesh@2002');
  print('='*70);
}
