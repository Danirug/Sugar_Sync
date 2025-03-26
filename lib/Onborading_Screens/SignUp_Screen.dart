import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SignUp_Screen extends StatefulWidget{
  const SignUp_Screen ({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUp_Screen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  String _userEmail = '';
  bool _acceptTerms = false;

  void _register() async{
    try{
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if(userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_firstNameController.text.trim());

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        });
        setState(() {
          _success = true;
          _userEmail = userCredential.user!.email!;
        });
        Navigator.pushNamed(context, 'DetailsScreen');
      }
    } on FirebaseAuthException catch (e){
      setState(() {
        _success = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}'),
          )
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Hey there,',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create An Account',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'Assets/Person01.png',
                      height: 200,
                      fit: BoxFit.contain,
                    )
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height:16),
                    TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          prefixIcon: Icon(Icons.person),
                        )
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline)
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value){
                            setState(() {
                              _acceptTerms = value!;
                            });
                          },
                        ),
                        Text('Accept terms and Conditions')
                      ],
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
                          )
                      ),
                      child: ElevatedButton(
                        onPressed: (){
                          if(_acceptTerms){
                            _register();
                            Navigator.pushNamed(context, 'DetailsScreen');
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please accept terms & condition'),
                                )
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            )
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, 'loginScreen');
                      },
                      child:Text('Already have an account? Login'),
                    )
                  ],
                ),
              ],
            )
        ),
      ),
    ),
    );
  }
}

//Navigator.pushNamed(context, 'DetailsScreen');


