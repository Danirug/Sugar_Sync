import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Welcome_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Splash_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/SignUp_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Login_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Deatils_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/MainDashboard_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/UpdatePersonalData_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Insights_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Settings_Screen.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Forgot_password.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBzmUaF-1K_K12Q5cD7FC9WdGU_76sTuCU",
          authDomain: "sugarsync-5baf6.firebaseapp.com",
          projectId: "sugarsync-5baf6",
          storageBucket: "sugarsync-5baf6.firebasestorage.app",
          messagingSenderId: "672757681028",
          appId: "1:672757681028:web:bf42c59ee3f37c751e2bd1"
      ),
    );
  } else {
    // Firebase initialization for mobile
    await Firebase.initializeApp();
  }
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'SyncSugar',
    version: '1.0.0',
  );
  runApp(const SyncSugar());
}

class SyncSugar extends StatelessWidget {
  const SyncSugar({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        initialRoute:"SplashScreen",
        routes: {
          "SplashScreen":(context)=>Splash_Screen(),
          "WelcomeScreen":(context)=>Welcome_Screen(),
          "loginScreen":(context)=>login_Screen(),
          "SignupScreen":(context)=>SignUp_Screen(),
          "DetailsScreen":(context)=>Details_Screen(),
          "DashBoardScreen":(context)=>Dashboard_Screen(),
          "UpdateScreen":(context)=>Update_Screen(),
          "InsightsScreen":(context)=>InsightsScreen(),
          "SettingScreen":(context)=>SettingsScreen(),
          "ForgotPassword":(context)=>ForgotPassword(),
        }
    );
  }
}
