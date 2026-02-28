// Quick helper to get your access token
// Add this to your app temporarily, then remove it

// Option 1: Add to AuthService after login
// In lib/services/auth_service.dart, in the login method after successful login:
/*
if (_accessToken != null) {
  print('═══════════════════════════════════════');
  print('🔑 YOUR ACCESS TOKEN:');
  print(_accessToken);
  print('═══════════════════════════════════════');
  print('Copy this token and paste it in scripts/insert_hotels.dart');
}
*/

// Option 2: Add a button in your app
// In any screen (like ProfileScreen):
/*
ElevatedButton(
  onPressed: () {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.accessToken;
    print('═══════════════════════════════════════');
    print('🔑 YOUR ACCESS TOKEN:');
    print(token);
    print('═══════════════════════════════════════');
    // Show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Access Token'),
        content: SelectableText(token ?? 'No token'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  },
  child: Text('Get Access Token'),
)
*/
