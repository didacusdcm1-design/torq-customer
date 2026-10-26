import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Make sure your NestJS backend is running on port 3000!
  final String baseUrl = 'https://torq-backend.onrender.com'; 

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['access_token']; // Returns the JWT token
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to backend: $e');
      return null;
    }
  }
}
