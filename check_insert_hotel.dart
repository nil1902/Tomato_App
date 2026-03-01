import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMGFlZTMxYS03M2RlLTQzNTEtODY4MS1jZDhlMTA4MDFmOTgiLCJlbWFpbCI6Im5pbGltZXNocGFsMTUrYWRtaW5AZ21haWwuY29tIiwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJpYXQiOjE3NzIzNjI3MzMsImV4cCI6MTc3MjM2MzYzM30.mQh_hJjSN8ZF3XoXqUSqjtJkVN_H5S5XwcVmFbo2RuE';
  
  final hotelData = {
    'name': 'Test Hotel',
    'location': 'Test Location',
    'city': 'Test City',
    'description': 'Test Description',
    'price_per_night': 1000,
    'base_price': 1000,
    'rating': 4.5,
    'couple_rating': 4.5,
    'star_rating': 4,
    'image_urls': [],
    'images': [],
    'is_active': true,
    'privacy_assured': true,
    'local_id_accepted': true,
    'amenities': [], 
  };

  try {
    final response = await http.post(
      Uri.parse('https://nukpc39r.ap-southeast.insforge.app/api/database/records/hotels'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$token',
        'Prefer': 'return=representation'
      },
      body: jsonEncode([hotelData]),
    );

    print('Status Code: \${response.statusCode}');
    print('Response Body: \${response.body}');
  } catch (e) {
    print('Failed: \$e');
  }
}
