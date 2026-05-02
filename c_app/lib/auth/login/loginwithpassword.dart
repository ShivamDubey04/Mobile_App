import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/auth/login/login_api_service.dart';
import 'package:flutter/material.dart';
import 'token_service.dart';

class PasswordLoginScreen extends StatefulWidget {
  final String email;
  PasswordLoginScreen({required this.email});

  @override
  _PasswordLoginScreenState createState() =>
      _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final passwordCtrl = TextEditingController();
  final api = LoginApiService();
  final tokenService = TokenService();

  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);

    final result =
        await api.loginWithPassword(widget.email, passwordCtrl.text);

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
          .showSnackBar(SnackBar(content: Text("Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Email: ${widget.email}"),

            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 20),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}