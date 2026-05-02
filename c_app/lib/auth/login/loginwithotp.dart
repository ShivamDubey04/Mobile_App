import 'dart:async';
import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/auth/login/login_api_service.dart';
import 'package:flutter/material.dart';
import 'token_service.dart';

class OtpLoginScreen extends StatefulWidget {
  final String email;
  OtpLoginScreen({required this.email});

  @override
  _OtpLoginScreenState createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final otpCtrl = TextEditingController();
  final api = LoginApiService();
  final tokenService = TokenService();

  int seconds = 30;
  bool canResend = false;
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    seconds = 30;
    canResend = false;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => seconds--);
      }
    });
  }

  void resendOtp() async {
    final success = await api.sendOtp(widget.email);

    if (success) {
      startTimer();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Resend failed")));
    }
  }

  void verifyOtp() async {
    setState(() => isLoading = true);

    final result = await api.verifyOtp(widget.email, otpCtrl.text);

    setState(() => isLoading = false);

    if (result != null) {
      await tokenService.saveTokens(
        result['token'],
        result['refreshToken'],
      );

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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("OTP sent to ${widget.email}"),

            TextField(
              controller: otpCtrl,
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyOtp,
                    child: Text("Verify"),
                  ),

            SizedBox(height: 20),

            canResend
                ? TextButton(
                    onPressed: resendOtp,
                    child: Text("Resend OTP"),
                  )
                : Text("Resend in $seconds sec"),
          ],
        ),
      ),
    );
  }
}