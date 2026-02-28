import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';

void main() async {
  print('🔐 Admin Role Setup Tool\n');
  print('This script will set admin role for your account.');
  print('You need to provide your access token.\n');
  
  print('How to get your access token:');
  print('1. Open your LoveNest app');
  print('2. Login with: nilimeshpal15@gmail.com');
  print('3. Check the console/logs for the access token');
  print('4. Copy the token and paste it here\n');
  
  print('Enter your access token:');
  final accessToken = stdin.readLineSync()?.trim();
  
  if (accessToken == null || accessToken.isEmpty) {
    print('❌ No token provided. Exiting.');
    return;
  }
  
  print('\n🔄 Setting admin role...\n');
  
  try {
    // Step 1: Get current user info
    print('Step 1: Fetching user info...');
    final userResponse = await http.get(
      Uri.parse('$baseUrl/api/auth/sessions/current'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (userResponse.statusCode != 200) {
      print('❌ Failed to get user info. Token might be invalid.');
      print('Response: ${userResponse.body}');
      return;
    }
    
    final userData = jsonDecode(userResponse.body);
    final userId = userData['user']['id'] ?? userData['user']['uid'];
    final userEmail = userData['user']['email'];
    
    print('✅ User found: $userEmail');
    print('User ID: $userId');
    
    // Step 2: Check if profile exists
    print('\nStep 2: Checking user profile...');
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
        print('✅ Profile found, updating to admin role...');
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
          print('✅ Admin role set successfully!');
          _printSuccess(userEmail);
        } else {
          print('⚠️  Update failed: ${updateResponse.statusCode}');
          print('Response: ${updateResponse.body}');
          
          // Check if role column exists
          if (updateResponse.body.contains('column') && updateResponse.body.contains('does not exist')) {
            print('\n❌ The "role" column does not exist in user_profiles table.');
            _printManualSQLInstructions(userEmail);
          }
        }
      } else {
        // Create profile with admin role
        print('Profile not found, creating with admin role...');
        final createResponse = await http.post(
          Uri.parse('$baseUrl/api/database/records/user_profiles'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          body: jsonEncode([{
            'user_id': userId,
            'name': userData['user']['name'] ?? 'Admin User',
            'email': userEmail,
            'role': 'admin',
          }]),
        );
        
        if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
          print('✅ Admin profile created successfully!');
          _printSuccess(userEmail);
        } else {
          print('⚠️  Profile creation failed: ${createResponse.statusCode}');
          print('Response: ${createResponse.body}');
          _printManualSQLInstructions(userEmail);
        }
      }
    } else {
      print('❌ Failed to check profile: ${checkResponse.statusCode}');
      print('Response: ${checkResponse.body}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}

void _printSuccess(String email) {
  print('\n' + '='*70);
  print('🎉 ADMIN ACCESS GRANTED!');
  print('='*70);
  print('\n✅ Your account now has full admin privileges');
  print('\n📧 Admin Email: $email');
  print('\n🔐 Admin Capabilities:');
  print('   ✓ Manage all hotels (add, edit, delete)');
  print('   ✓ View and manage all bookings');
  print('   ✓ Manage user accounts');
  print('   ✓ Access analytics dashboard');
  print('   ✓ Full database access');
  print('\n📱 Next Steps:');
  print('   1. Restart your LoveNest app');
  print('   2. Login with your credentials');
  print('   3. Go to Settings → Admin Panel');
  print('   4. Start managing your platform!');
  print('='*70);
}

void _printManualSQLInstructions(String email) {
  print('\n' + '='*70);
  print('⚠️  MANUAL DATABASE UPDATE REQUIRED');
  print('='*70);
  print('\nThe "role" column needs to be added to your database.');
  print('\nRun this SQL in your InsForge database console:');
  print('');
  print('-- Add role column if it doesn\'t exist');
  print('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT \'user\';');
  print('');
  print('-- Set admin role for your account');
  print('UPDATE user_profiles SET role = \'admin\' WHERE email = \'$email\';');
  print('');
  print('\nAfter running the SQL:');
  print('1. Restart your app');
  print('2. Login with your credentials');
  print('3. Admin panel will be available in Settings');
  print('='*70);
}
