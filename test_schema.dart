import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMGFlZTMxYS03M2RlLTQzNTEtODY4MS1jZDhlMTA4MDFmOTgiLCJlbWFpbCI6Im5pbGltZXNocGFsMTUrYWRtaW5AZ21haWwuY29tIiwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJpYXQiOjE3NzIzNjI3MzMsImV4cCI6MTc3MjM2MzYzM30.mQh_hJjSN8ZF3XoXqUSqjtJkVN_H5S5XwcVmFbo2RuE';
  
  final hotelData = {
    'name': 'Test Hotel',
    'location': 'Test Location',
    'description': 'Test Description',
    'rating': 4.5,
    'image_urls': [],
    'is_active': true,
    'couple_friendly': true,
    'local_id_allowed': true,
    'privacy_score': 9.5,
    'safety_verified': true,
    'amenities': [], 
  };

  try {
    final response = await http.post(
      Uri.parse('https://nukpc39r.ap-southeast.insforge.app/api/database/records/hotels'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \',
        'Prefer': 'return=representation'
      },
      body: jsonEncode([hotelData]),
    );

    print('Status Code: \');
    print('Response Body: \');
  } catch (e) {
    print('Failed: \');
  }
}
