import 'package:flutter/material.dart';



class Splash_Screen extends StatelessWidget{
  const Splash_Screen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //logo
              Column(
                children: [
                  SizedBox(height: 300),
                  Text(
                    'SyncSugar.',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SIMPLIFY YOUR HEALTH, SYNC YOUR LIFE',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              //button
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3498DB),
                        Color(0xFF1C5175),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, 'WelcomeScreen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

