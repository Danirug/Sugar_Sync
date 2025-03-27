import 'package:flutter/material.dart';

class Welcome_Screen extends StatelessWidget{
  const Welcome_Screen({super.key});

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
                Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      'Welcome to Sync Sugar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                        'Assets/Welcome.png',
                      height: 450,
                      fit: BoxFit.fill,
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF3498DB),
                              Color(0xFF1C5175),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.pushNamed(context, 'loginScreen');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),

                          ),
                        )
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3498DB),
                            Color(0xFF1C5175),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.pushNamed(context, 'SignupScreen');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),

                  ],
                )
              ],
            )
        ),
      ),

    );
  }

}