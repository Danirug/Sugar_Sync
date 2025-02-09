import 'package:flutter/material.dart';

void main() {
  runApp(const SugarSync());
}

class SugarSync extends StatelessWidget {
  const SugarSync({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
        initialRoute:"SplashScreen",
        routes: {
          "SplashScreen":(context)=>Splash_Screen(),
          "WelcomeScreen":(context)=>Welcome_Screen(),
          "loginScreen":(context)=>login_Screen(),
          "SignupScreen":(context)=>SignUp_Screen(),
          "DetailsScreen":(context)=>Details_Screen()
          //"ForgotPassword":(context)=>
        }
    );
  }
}
