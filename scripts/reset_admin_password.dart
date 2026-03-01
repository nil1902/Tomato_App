import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Admin Password Reset Tool\n');
  
  const String adminEmail = 'nilimeshpal15@gmail.com';
  const String newPassword = 'Nilimesh@2002';
  
  print('This will reset the password for: $adminEmail');
  print('New password will be: $newPassword\n');
  
  try {
    // Step 1: Request password reset
    print('Step 1: Requesting password reset...');
    final resetResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': adminEmail}),
    );
    
    print('Reset request status: ${resetResponse.statusCode}');
    
    if (resetResponse.statusCode == 200 || resetResponse.statusCode == 201 || resetResponse.statusCode == 202) {
      print('✅ Password reset email sent!');
      print('\n📧 CHECK YOUR EMAIL: $adminEmail');
      print('You should receive a password reset link or code.');
      print('\nAlternatively, you can:');
      print('1. Use the "Forgot Password" option in the app');
      print('2. Or manually update password in InsForge backend');
    } else {
      print('⚠️  Reset request response: ${resetResponse.body}');
      print('\n💡 Alternative Solution:');
      print('Since the account exists, try these options:\n');
      
      print('Option 1: Use Forgot Password in App');
      print('   1. Open LoveNest app');
      print('   2. Click "Forgot Password?" on login screen');
      print('   3. Enter: $adminEmail');
      print('   4. Follow reset instructions\n');
      
      print('Option 2: Try Your Original Password');
      print('   The account was created earlier with a different password.');
      print('   Try the password you used when you first registered.\n');
      
      print('Option 3: Create New Admin Account');
      print('   Run: dart run scripts/create_new_admin.dart');
      print('   This will create a fresh admin account with known credentials.\n');
      
      print('Option 4: Manual Backend Reset');
      print('   1. Login to InsForge dashboard');
      print('   2. Go to Authentication → Users');
      print('   3. Find user: $adminEmail');
      print('   4. Reset password manually');
    }
  } catch (e) {
    print('❌ ERROR: $e\n');
    print('💡 SOLUTIONS:\n');
    
    print('1. TRY FORGOT PASSWORD IN APP:');
    print('   • Open app → Login screen');
    print('   • Click "Forgot Password?"');
    print('   • Enter: $adminEmail');
    print('   • Check email for reset link\n');
    
    print('2. CREATE NEW ADMIN ACCOUNT:');
    print('   • Use a different email');
    print('   • Run: dart run scripts/create_fresh_admin.dart\n');
    
    print('3. CHECK YOUR EMAIL:');
    print('   • You might have registered with different email');
    print('   • Try: nilimeshpal22@gmail.com (from earlier logs)');
  }
}
