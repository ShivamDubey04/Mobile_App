import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/auth/register/registerservice.dart';
import 'package:c_app/auth/register/tokenstorageservice.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  OtpScreen({required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpCtrl = TextEditingController();
  final api = ApiService();
  final tokenService = TokenService();

void verifyOtp() async {
  final result = await api.verifyOtp(widget.email, otpCtrl.text);

  if (result != null) {
    // ✅ correct keys from your API
    final accessToken = result['token'];
    final refreshToken = result['refreshToken'];

    await tokenService.saveTokens(accessToken, refreshToken);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Invalid OTP")));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Enter 6-digit OTP"),
            TextField(
              controller: otpCtrl,
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(onPressed: verifyOtp, child: Text("Verify"))
          ],
        ),
      ),
    );
  }
}