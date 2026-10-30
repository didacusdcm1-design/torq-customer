import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://torq-backend.onrender.com';
  
  // --- TOKEN MANAGEMENT ---
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // --- AUTHENTICATION ---
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        await saveToken(data['access_token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: Ensure backend is awake.'};
    }
  }

  static Future<Map<String, dynamic>> register(String phone, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone, 
          'password': password, 
          'email': email,
          'role': 'CUSTOMER'
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Registration successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  // --- TRIP DISPATCH ---
  static Future<Map<String, dynamic>> requestTrip({
    required double pickupLat, 
    required double pickupLng, 
    required double dropoffLat, 
    required double dropoffLng,
    required double distanceKm,
    required double durationMins
  }) async {
    try {
      final token = await getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/trips/dispatch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'pickupLat': pickupLat,
          'pickupLng': pickupLng,
          'dropoffLat': dropoffLat,
          'dropoffLng': dropoffLng,
          'distanceKm': distanceKm,
          'durationMins': durationMins
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true, 
          'pickupPin': data['trip']['pickupPin'],
          'trip': data['trip']
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Dispatch failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
  static Future<Map<String, dynamic>> rateTrip(String tripId, int rating) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/trips/$tripId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'rating': rating}),
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Failed to submit rating'};
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
  static Future<Map<String, dynamic>?> getCustomerActiveTrip() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/trips/customer/active'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null) return null;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  static Future<bool> cancelTrip(String tripId, String cancelledBy, String reason, String note) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/trips/cancel/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'cancelledBy': cancelledBy,
          'reason': reason,
          'note': note,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
