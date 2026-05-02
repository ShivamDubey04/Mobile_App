import 'package:c_app/auth/login/login_screen.dart';
import 'package:c_app/auth/register/registerservice.dart';
import 'package:c_app/auth/register/verify_otp.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final api = ApiService();


void login(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
}

  void register() async {
    final success = await api.register(
      usernameCtrl.text,
      emailCtrl.text,
      passwordCtrl.text,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: emailCtrl.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: usernameCtrl, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordCtrl, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Register")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login"))
          ],
        ),
      ),
    );
  }
}