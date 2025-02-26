import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String apiUrl =
      "https://bustrackingapp-oezp.onrender.com/api/auth/login"; // Update with your backend URL

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }
}
