import 'package:c_app/auth/login/login_api_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final api = LoginApiService();

  bool isLoading = false;

  void sendResetLink() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter email")));
      return;
    }

    setState(() => isLoading = true);

    final success = await api.forgotPassword(emailCtrl.text);

    setState(() => isLoading = false);

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Email Sent"),
          content: Text(
              "Password reset link has been sent to your email.\nPlease check your inbox."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // go back to login
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reset email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Enter your registered email",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: "Email"),
            ),

            SizedBox(height: 20),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: sendResetLink,
                    child: Text("Send Reset Link"),
                  ),
          ],
        ),
      ),
    );
  }
}