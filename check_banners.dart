import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('https://nukpc39r.ap-southeast.insforge.app/api/database/records/banners'));
    print('STATUS: \${response.statusCode}');
    print('BODY: \${response.body}');
  } catch (e) {
    print('ERROR: \$e');
  }
}
