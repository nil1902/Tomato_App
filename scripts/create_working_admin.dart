import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Creating Working Admin Account\n');
  
  // Using a completely new email to avoid conflicts
  const String adminEmail = 'lovenest.admin@gmail.com';
  const String adminPassword = 'Admin@123456';
  const String adminName = 'LoveNest Admin';
  
  print('Creating admin account with:');
  print('Email: $adminEmail');
  print('Password: $adminPassword');
  print('Name: $adminName\n');
  
  try {
    // Step 1: Register
    print('Step 1: Registering admin account...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': adminEmail,
        'password': adminPassword,
        'name': adminName,
      }),
    );
    
    print('Status: ${registerResponse.statusCode}');
    print('Response: ${registerResponse.body}\n');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      final data = jsonDecode(registerResponse.body);
      
      if (data['accessToken'] != null) {
        // Got token immediately - no verification needed
        print('✅ Account created and verified automatically!\n');
        final accessToken = data['accessToken'];
        final userId = data['user']['id'] ?? data['user']['uid'];
        await _setAdminRole(accessToken, userId, adminName, adminEmail);
      } else {
        // Needs verification
        print('📧 Email verification required');
        print('But don\'t worry - I\'ll create a backup solution...\n');
        await _createBackupAdmin();
      }
    } else if (registerResponse.body.contains('already exists')) {
      print('Account exists. Trying backup solution...\n');
      await _createBackupAdmin();
    } else {
      print('Creating backup admin account...\n');
      await _createBackupAdmin();
    }
  } catch (e) {
    print('Error: $e\n');
    print('Creating backup solution...\n');
    await _createBackupAdmin();
  }
}

Future<void> _createBackupAdmin() async {
  // Create with timestamp to ensure uniqueness
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final backupEmail = 'admin$timestamp@lovenest.app';
  const backupPassword = 'Admin@123456';
  const backupName = 'LoveNest Admin';
  
  print('Creating backup admin:');
  print('Email: $backupEmail');
  print('Password: $backupPassword\n');
  
  try {
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': backupEmail,
        'password': backupPassword,
        'name': backupName,
      }),
    );
    
    print('Status: ${registerResponse.statusCode}');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      final data = jsonDecode(registerResponse.body);
      
      if (data['accessToken'] != null) {
        final accessToken = data['accessToken'];
        final userId = data['user']['id'] ?? data['user']['uid'];
        await _setAdminRole(accessToken, userId, backupName, backupEmail);
      } else {
        _printManualSolution(backupEmail, backupPassword);
      }
    } else {
      _printManualSolution(backupEmail, backupPassword);
    }
  } catch (e) {
    print('Error: $e');
    _printSimplestSolution();
  }
}

Future<void> _setAdminRole(String accessToken, String userId, String name, String email) async {
  try {
    print('Setting admin role...');
    
    // Create profile with admin role
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
      print('✅ Admin role set!\n');
      _printSuccess(email, 'Admin@123456');
    } else {
      print('Profile response: ${profileResponse.body}\n');
      _printManualSolution(email, 'Admin@123456');
    }
  } catch (e) {
    print('Error setting role: $e');
    _printManualSolution(email, 'Admin@123456');
  }
}

void _printSuccess(String email, String password) {
  print('═══════════════════════════════════════════════════════════════');
  print('🎉 SUCCESS! YOUR ADMIN ACCOUNT IS READY!');
  print('═══════════════════════════════════════════════════════════════');
  print('');
  print('📧 LOGIN CREDENTIALS:');
  print('   Email: $email');
  print('   Password: $password');
  print('');
  print('🚀 HOW TO LOGIN:');
  print('   1. Open your LoveNest app');
  print('   2. Use the credentials above');
  print('   3. You\'ll have full admin access!');
  print('');
  print('⚠️  SAVE THESE CREDENTIALS NOW!');
  print('═══════════════════════════════════════════════════════════════');
}

void _printManualSolution(String email, String password) {
  print('═══════════════════════════════════════════════════════════════');
  print('⚠️  MANUAL SETUP REQUIRED');
  print('═══════════════════════════════════════════════════════════════');
  print('');
  print('Your account has been created:');
  print('Email: $email');
  print('Password: $password');
  print('');
  print('To set admin role, run this SQL in InsForge:');
  print('');
  print('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT \'user\';');
  print('UPDATE user_profiles SET role = \'admin\' WHERE email = \'$email\';');
  print('');
  print('Then login with the credentials above.');
  print('═══════════════════════════════════════════════════════════════');
}

void _printSimplestSolution() {
  print('═══════════════════════════════════════════════════════════════');
  print('💡 SIMPLEST SOLUTION - USE YOUR EXISTING ACCOUNT');
  print('═══════════════════════════════════════════════════════════════');
  print('');
  print('Since registration is having issues, let\'s use your existing account:');
  print('');
  print('OPTION 1: Try your other email');
  print('   Email: nilimeshpal22@gmail.com');
  print('   Password: [Your password]');
  print('');
  print('OPTION 2: Register a new account in the app');
  print('   1. Open LoveNest app');
  print('   2. Click "Register"');
  print('   3. Use email: admin.lovenest@gmail.com');
  print('   4. Password: Admin@123456');
  print('   5. Complete registration');
  print('   6. Then I\'ll set admin role');
  print('');
  print('OPTION 3: Login to InsForge Dashboard');
  print('   1. Go to your InsForge backend');
  print('   2. Check registered users');
  print('   3. Find your email');
  print('   4. Reset password there');
  print('   5. Set role to admin');
  print('═══════════════════════════════════════════════════════════════');
}
