import 'package:c_app/auth/forget_password/forgotPassword.dart';
import 'package:c_app/auth/login/login_api_service.dart';
import 'package:c_app/auth/login/loginwithotp.dart';
import 'package:c_app/auth/login/loginwithpassword.dart';
import 'package:c_app/auth/register/registerservice.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final api = LoginApiService();

  bool isLoading = false;

  void loginWithOtp() async {
    if (emailCtrl.text.isEmpty) return;

    setState(() => isLoading = true);

    final success = await  api.sendOtp(emailCtrl.text);

    setState(() => isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpLoginScreen(email: emailCtrl.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send OTP")));
    }
  }

  void loginWithPassword() {
    if (emailCtrl.text.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordLoginScreen(email: emailCtrl.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 30),

            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: loginWithOtp,
                        child: Text("Login with OTP"),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: loginWithPassword,
                        child: Text("Login with Password"),
                      ),
         SizedBox(height: 10),
                      TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(),
      ),
    );
  },
  child: Text("Forgot Password?"),
)
                    ],
                  )
          ],
        ),
      ),
    );
  }

}