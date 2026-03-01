import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 REGISTERING NILIMESH AS ADMIN\n');
  
  const String email = 'nilimeshpal15@gmail.com';
  const String password = 'Admin@12345';
  const String name = 'Nilimesh Pal';
  
  print('Registering:');
  print('Email: $email');
  print('Password: $password');
  print('Name: $name\n');
  
  try {
    // Register
    print('Step 1: Registering account...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    print('Status: ${registerResponse.statusCode}');
    print('Response: ${registerResponse.body}\n');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      print('✅ ACCOUNT REGISTERED!\n');
      print('═══════════════════════════════════════════════════════════════');
      print('📧 CHECK YOUR EMAIL: $email');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('NEXT STEPS:');
      print('1. Check your email inbox');
      print('2. Find the verification code');
      print('3. Open your LoveNest app');
      print('4. Enter the verification code');
      print('5. Login with:');
      print('   Email: $email');
      print('   Password: $password');
      print('');
      print('6. After login, check console for access token');
      print('7. Run: dart run scripts/set_admin_role.dart');
      print('8. Paste your access token');
      print('');
      print('DONE! You\'ll have full admin access!');
      print('═══════════════════════════════════════════════════════════════');
    } else if (registerResponse.body.contains('already exists') || 
               registerResponse.body.contains('User already registered')) {
      print('⚠️  ACCOUNT ALREADY EXISTS!\n');
      print('═══════════════════════════════════════════════════════════════');
      print('Your email is already registered.');
      print('');
      print('OPTION 1: Login with existing password');
      print('   • Try your original password');
      print('   • If it works, get access token');
      print('   • Run: dart run scripts/set_admin_role.dart');
      print('');
      print('OPTION 2: Delete old account and re-register');
      print('   • Go to InsForge dashboard');
      print('   • Delete user: $email');
      print('   • Run this script again');
      print('');
      print('OPTION 3: Use different email');
      print('   • Try: nilimeshpal15+admin@gmail.com');
      print('   • Verification will go to same inbox');
      print('═══════════════════════════════════════════════════════════════');
    } else {
      print('❌ Registration failed');
      print('Response: ${registerResponse.body}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
