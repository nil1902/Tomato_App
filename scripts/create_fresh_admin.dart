import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Creating Fresh Admin Account\n');
  
  // Use a slightly different email to avoid conflicts
  const String adminEmail = 'admin.nilimesh@lovenest.com';
  const String adminPassword = 'Nilimesh@2002';
  const String adminName = 'Nilimesh Pal (Admin)';
  
  print('Creating new admin account:');
  print('Email: $adminEmail');
  print('Password: $adminPassword');
  print('Name: $adminName\n');
  
  try {
    // Register new admin user
    print('Step 1: Registering new admin account...');
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
      print('✅ Admin account created successfully!\n');
      
      // Check if we got tokens immediately
      if (registerData['accessToken'] != null) {
        final accessToken = registerData['accessToken'];
        final userId = registerData['user']['id'] ?? registerData['user']['uid'];
        
        print('✅ Account verified automatically');
        await _setAdminRole(accessToken, userId, adminName, adminEmail);
      } else {
        print('📧 EMAIL VERIFICATION REQUIRED');
        print('═══════════════════════════════════════════════════════════');
        print('Check your email: $adminEmail');
        print('Enter the verification code to complete setup');
        print('After verification, login with these credentials:');
        print('');
        print('Email: $adminEmail');
        print('Password: $adminPassword');
        print('═══════════════════════════════════════════════════════════');
      }
    } else {
      print('⚠️  Registration response: ${registerResponse.body}\n');
      
      if (registerResponse.body.contains('already exists')) {
        print('Account already exists. Trying to login and set admin role...\n');
        await _loginAndSetAdmin(adminEmail, adminPassword, adminName);
      } else {
        _printAlternativeSolution();
      }
    }
  } catch (e) {
    print('❌ ERROR: $e\n');
    _printAlternativeSolution();
  }
}

Future<void> _loginAndSetAdmin(String email, String password, String name) async {
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
      await _setAdminRole(accessToken, userId, name, email);
    } else {
      print('❌ Login failed: ${loginResponse.body}');
      _printAlternativeSolution();
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
}

Future<void> _setAdminRole(String accessToken, String userId, String name, String email) async {
  try {
    print('\nStep 2: Setting admin role...');
    
    // Check if profile exists
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
        // Update existing profile
        final profileId = profiles[0]['id'];
        
        final updateResponse = await http.patch(
          Uri.parse('$baseUrl/api/database/records/user_profiles?id=eq.$profileId'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          body: jsonEncode({'role': 'admin'}),
        );
        
        if (updateResponse.statusCode == 200 || updateResponse.statusCode == 204) {
          print('✅ Admin role set successfully!');
          _printSuccess(email, 'Nilimesh@2002');
        } else {
          print('⚠️  Role update failed: ${updateResponse.body}');
          _printManualInstructions(email);
        }
      } else {
        // Create new profile
        final createResponse = await http.post(
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
        
        if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
          print('✅ Admin profile created!');
          _printSuccess(email, 'Nilimesh@2002');
        } else {
          print('⚠️  Profile creation failed: ${createResponse.body}');
          _printManualInstructions(email);
        }
      }
    }
  } catch (e) {
    print('❌ Error setting admin role: $e');
  }
}

void _printSuccess(String email, String password) {
  print('\n${'='*70}');
  print('🎉 ADMIN ACCOUNT READY!');
  print('='*70);
  print('\n📧 Login Credentials:');
  print('   Email: $email');
  print('   Password: $password');
  print('\n🔐 You now have FULL ADMIN ACCESS!');
  print('\n📱 Next Steps:');
  print('   1. Open your LoveNest app');
  print('   2. Login with the credentials above');
  print('   3. Go to Settings → Admin Panel');
  print('   4. Start managing your platform!');
  print('\n⚠️  SAVE THESE CREDENTIALS SECURELY!');
  print('='*70);
}

void _printManualInstructions(String email) {
  print('\n${'='*70}');
  print('⚠️  MANUAL SETUP NEEDED');
  print('='*70);
  print('\nRun this SQL in your InsForge database:');
  print('');
  print('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT \'user\';');
  print('UPDATE user_profiles SET role = \'admin\' WHERE email = \'$email\';');
  print('');
  print('Then login with:');
  print('Email: $email');
  print('Password: Nilimesh@2002');
  print('='*70);
}

void _printAlternativeSolution() {
  print('\n${'='*70}');
  print('💡 ALTERNATIVE SOLUTIONS');
  print('='*70);
  print('\n1. USE YOUR EXISTING ACCOUNT:');
  print('   Email: nilimeshpal15@gmail.com');
  print('   Try your original password (not Nilimesh@2002)');
  print('   Or use "Forgot Password" in the app\n');
  
  print('2. USE THE OTHER REGISTERED EMAIL:');
  print('   Email: nilimeshpal22@gmail.com');
  print('   This email was used in earlier sessions');
  print('   Try logging in with this\n');
  
  print('3. RESET PASSWORD VIA APP:');
  print('   • Open app → Login screen');
  print('   • Click "Forgot Password?"');
  print('   • Enter your email');
  print('   • Follow reset instructions\n');
  
  print('4. CHECK INSFORGE DASHBOARD:');
  print('   • Login to InsForge backend');
  print('   • Check which emails are registered');
  print('   • Reset password from there');
  print('='*70);
}
