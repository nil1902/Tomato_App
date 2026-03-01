import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nukpc39r.ap-southeast.insforge.app';
const String accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmNDJhOTJjYi1jY2FhLTQ2MTYtYmQxNC02OTM2YTkyNmE1ZGUiLCJlbWFpbCI6Im5pbGltZXNocGFsMjJAZ21haWwuY29tIiwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJpYXQiOjE3NzIyMjQxNTIsImV4cCI6MTc3MjIyNTA1Mn0.bnrlfX_skQU1KTZO35nu4npTEpIVjdM5RMnRASDzbC4';

void main() async {
  print('Testing hotel insert with minimal fields...\n');
  
  // First, let's try to get existing hotels to see what fields they have
  print('1. Fetching existing hotels...');
  try {
    final getResponse = await http.get(
      Uri.parse('$baseUrl/api/database/records/hotels?limit=1'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    print('GET Status: ${getResponse.statusCode}');
    if (getResponse.statusCode == 200) {
      final data = jsonDecode(getResponse.body);
      if (data.isNotEmpty) {
        print('Existing hotel structure:');
        print(JsonEncoder.withIndent('  ').convert(data[0]));
      } else {
        print('No existing hotels found');
      }
    } else {
      print('GET Response: ${getResponse.body}');
    }
  } catch (e) {
    print('GET Error: $e');
  }
  
  print('\n2. Trying to insert one hotel...');
  final hotel = {
    'name': 'Test Hotel',
    'description': 'A test hotel',
    'city': 'Test City',
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/database/records/hotels'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: jsonEncode([hotel]),
    );

    print('POST Status: ${response.statusCode}');
    print('POST Response: ${response.body}');
  } catch (e) {
    print('POST Error: $e');
  }
}
