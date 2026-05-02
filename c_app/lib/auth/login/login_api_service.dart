import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginApiService {
  final String baseUrl = "https://auth.arteliainstitute.com"; // 🔴 CHANGE THIS

  Future<bool> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/send-login-otp?email=$email"),
      headers: {"Content-Type": "application/json"},
      // body: jsonEncode({"email": email}),
    );

    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/verify-login-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otpCode": otp,
      }),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 200) {
        return json['data'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginWithPassword(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 200) {
        return json['data'];
      }
    }
    return null;
  }





  Future<bool> forgotPassword(String email) async {
  final res = await http.post(
    Uri.parse("$baseUrl/api/auth/forgot-password"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  if (res.statusCode == 200) {
    final json = jsonDecode(res.body);
    return json['status'] == 200;
  }

  return false;
}
}