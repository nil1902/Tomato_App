class ApiConstants {
  static const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';
  
  // Default headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  // Headers with authorization token
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ImgBB API Key for Free external image hosting
  // GET A FREE KEY AT: https://api.imgbb.com/ (Takes 10 seconds)
  static const String imgbbApiKey = 'INSERT_YOUR_IMGBB_KEY_HERE';
}
