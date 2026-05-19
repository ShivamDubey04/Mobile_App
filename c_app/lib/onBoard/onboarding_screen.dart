import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/auth/login/login_screen.dart';
import 'package:c_app/auth/register/register.dart';
import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome",
      "desc": "Experience something amazing",
      "image": "assets/img1.png",
    },
    {
      "title": "Discover",
      "desc": "Find what you need easily",
      "image": "assets/img2.png",
    },
    {
      "title": "Get Started",
      "desc": "Let's begin your journey",
      "image": "assets/img3.png",
    },
  ];

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      // MaterialPageRoute(builder: (_) => RegisterScreen()),
       MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Pages
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });

              /// Auto move to login on last page swipe
              if (index == onboardingData.length - 1) {
                Future.delayed(Duration(milliseconds: 800), () {
                  goToLogin();
                });
              }
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  /// Background Image
                  SizedBox.expand(
                    child: Image.asset(
                      onboardingData[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  /// Text
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          onboardingData[index]["title"]!,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          onboardingData[index]["desc"]!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// 🔹 Minimal Indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          /// 🔹 Skip (top-right, subtle)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: goToLogin,
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}