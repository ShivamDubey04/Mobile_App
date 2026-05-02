import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://auth.arteliainstitute.com";

  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );
    return response.statusCode == 200;
  }

Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
  final response = await http.post(
    Uri.parse("$baseUrl/api/auth/verify-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otpCode": otp,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    if (json['status'] == 200) {
      return json['data']; // ✅ return only data
    }
  }

  return null;
}
}