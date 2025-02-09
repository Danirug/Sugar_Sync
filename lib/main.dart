import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Welcome_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Splash_Screen.dart';

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
