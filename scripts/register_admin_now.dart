import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 REGISTERING YOUR ADMIN ACCOUNT NOW!\n');
  
  // Using +admin trick - verification goes to nilimeshpal15@gmail.com
  const String email = 'nilimeshpal15+admin@gmail.com';
  const String password = 'Admin@12345';
  const String name = 'Nilimesh Pal (Admin)';
  
  print('Registering:');
  print('Email: $email');
  print('Password: $password');
  print('Verification emails go to: nilimeshpal15@gmail.com\n');
  
  try {
    print('Registering account...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    print('Status: ${registerResponse.statusCode}\n');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      print('✅ SUCCESS! ACCOUNT CREATED!\n');
      print('═══════════════════════════════════════════════════════════════');
      print('🎉 YOUR ADMIN ACCOUNT IS REGISTERED!');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('📧 CHECK YOUR EMAIL: nilimeshpal15@gmail.com');
      print('   (Verification code was sent there)');
      print('');
      print('🔑 YOUR LOGIN CREDENTIALS:');
      print('   Email: $email');
      print('   Password: $password');
      print('');
      print('📱 NEXT STEPS:');
      print('   1. Check email: nilimeshpal15@gmail.com');
      print('   2. Copy the verification code');
      print('   3. Open LoveNest app');
      print('   4. Enter verification code');
      print('   5. Login with credentials above');
      print('   6. Check console for ACCESS TOKEN');
      print('   7. Run: dart run scripts/set_admin_role.dart');
      print('   8. Paste your access token');
      print('');
      print('✅ DONE! You\'ll have FULL ADMIN ACCESS!');
      print('═══════════════════════════════════════════════════════════════');
    } else {
      print('Response: ${registerResponse.body}\n');
      
      if (registerResponse.body.contains('already exists')) {
        print('This email variant also exists. Let me try another...\n');
        await _tryAlternative();
      } else {
        print('Registration had an issue. Trying alternative...\n');
        await _tryAlternative();
      }
    }
  } catch (e) {
    print('Error: $e\n');
    await _tryAlternative();
  }
}

Future<void> _tryAlternative() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'nilimesh.admin.$timestamp@lovenest.app';
  const password = 'Admin@12345';
  const name = 'Nilimesh Admin';
  
  print('Trying alternative email: $email\n');
  
  try {
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/users?client_type=mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    print('Status: ${registerResponse.statusCode}\n');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      print('✅ ALTERNATIVE ACCOUNT CREATED!\n');
      print('═══════════════════════════════════════════════════════════════');
      print('🔑 YOUR ADMIN CREDENTIALS:');
      print('   Email: $email');
      print('   Password: $password');
      print('');
      print('⚠️  This email needs verification');
      print('   But you can\'t access it...');
      print('');
      print('💡 BETTER SOLUTION:');
      print('   1. Open your LoveNest app');
      print('   2. Click REGISTER (not login)');
      print('   3. Use: nilimeshpal15+lovenest@gmail.com');
      print('   4. Password: Admin@12345');
      print('   5. Verification goes to: nilimeshpal15@gmail.com');
      print('   6. Complete verification');
      print('   7. Login and get access token');
      print('   8. Run: dart run scripts/set_admin_role.dart');
      print('═══════════════════════════════════════════════════════════════');
    } else {
      print('═══════════════════════════════════════════════════════════════');
      print('💡 MANUAL REGISTRATION REQUIRED');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('DO THIS IN YOUR APP:');
      print('1. Open LoveNest app');
      print('2. Click "Register"');
      print('3. Enter:');
      print('   Email: nilimeshpal15+lovenest@gmail.com');
      print('   Password: Admin@12345');
      print('   Name: Nilimesh Admin');
      print('');
      print('4. Check email: nilimeshpal15@gmail.com');
      print('5. Enter verification code');
      print('6. Login successfully');
      print('7. Copy access token from console');
      print('8. Run: dart run scripts/set_admin_role.dart');
      print('9. Paste token');
      print('');
      print('DONE! Full admin access granted!');
      print('═══════════════════════════════════════════════════════════════');
    }
  } catch (e) {
    print('Error: $e');
  }
}
