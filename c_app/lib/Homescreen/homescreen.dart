import 'package:c_app/auth/login/login_screen.dart';
import 'package:c_app/auth/login/token_service.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  final TokenService tokenService = TokenService();

  void logout(BuildContext context) async {
    await tokenService.clear(); // 🔥 clear tokens

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false, // 🔥 remove all previous screens
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: Text("Logout"),
        ),
      ),
    );
  }
}