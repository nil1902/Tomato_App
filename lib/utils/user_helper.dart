// Helper function to get user ID from user map
String? getUserId(Map<String, dynamic>? user) {
  if (user == null) return null;
  return user['id']?.toString() ?? 
         user['uid']?.toString() ?? 
         user['user_id']?.toString() ?? 
         user['email']?.toString();
}
