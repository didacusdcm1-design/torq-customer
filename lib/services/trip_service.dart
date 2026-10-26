import 'dart:convert';
import 'package:http/http.dart' as http;

class TripService {
  final String baseUrl = 'https://torq-backend.onrender.com';

  Future<bool> requestTrip(String token, double pickupLat, double pickupLng, double dropoffLat, double dropoffLng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trips/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "pickupLat": pickupLat,
          "pickupLng": pickupLng,
          "dropoffLat": dropoffLat,
          "dropoffLng": dropoffLng,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getTripHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trips/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

