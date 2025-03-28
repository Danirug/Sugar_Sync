import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Stateful widget for the Splash Screen
class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// State class for Splash Screen with animation
class _SplashScreenState extends State <Splash_Screen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      // Setting up animation controller with 5-second duration
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    // Creating linear progress animation from 0 to 1
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    _animationController.forward();//Starting animation
    _checkLoginStateAndNavigate();// Checking login state and navigating
  }

  Future<void> _checkLoginStateAndNavigate() async{
    // Add a delay to show the splash screen for a few seconds
    await Future.delayed(Duration(seconds: 5));

    // Check if the user is logged in
    final prefs = await SharedPreferences.getInstance();// Getting instance of shared preferences
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;// Checking if user is logged in, defaulting to false if not set

    // Navigate based on login state
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, 'DashBoardScreen');
    } else {
      Navigator.pushReplacementNamed(context, 'WelcomeScreen');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'Assets/Logo01.png',
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'SIMPLIFY YOUR HEALTH, SYNC YOUR LIFE',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child){
                      return LinearProgressIndicator(
                        // Current value of progress animation
                        value: _progressAnimation.value,
                        backgroundColor: Colors.black12,
                        // Progress color
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

