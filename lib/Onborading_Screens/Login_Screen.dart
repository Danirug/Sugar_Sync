import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class login_Screen extends StatefulWidget {
  const login_Screen({super.key});

  @override
  _login_ScreenState createState() => _login_ScreenState();
}


class _login_ScreenState extends State<login_Screen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _login() async{
    setState(() {
      _isLoading = true;
    });
    try{
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print("login succesfull");
      //if successful navigate to the main dashboard
      //put the route screen here
      Navigator.pushNamed(context, 'DashBoardScreen');
    }on FirebaseAuthException catch (e){
      print("login failed: ${e.code} - ${e.message}");

      String errorMessage = 'An error occured, Please try again';

      if(e.code == 'user-not-found'){
        errorMessage = 'No account found with this email.';
      }else if (e.code == 'wrong-password'){
        errorMessage = 'Incorrect password. Try again';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally{
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: SafeArea(
        child : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText:'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: (){},
                      child: Text('forgot your Password?'),
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3498DB),
                          Color(0xFF1C5175),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: (){
                        print('button pressed');
                        Navigator.pushNamed(context, 'SignupScreen');
                      },
                      child: Text('Don\'t have and account yet? Register'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        ),
      ),
    );
  }
}


