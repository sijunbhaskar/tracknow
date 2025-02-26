import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApiService {
  static const String baseUrl = 'https://bustrackingapp-oezp.onrender.com';

  // Fetch all bus locations
  static Future<List<Map<String, dynamic>>> getAllBuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/buses'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((bus) => {
                  "busId": bus['busId'],
                  "location": LatLng(bus['latitude'], bus['longitude']),
                })
            .toList();
      } else {
        throw Exception('Failed to load bus locations');
      }
    } catch (e) {
      print('Error fetching buses: $e');
      return [];
    }
  }
}
