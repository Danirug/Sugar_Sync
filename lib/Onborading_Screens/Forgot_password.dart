import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Controller for email input
  final TextEditingController _emailController = TextEditingController();
  // Loading state indicator
  bool _isLoading = false;

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    // Check if email field is empty
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email using Firebase Auth
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
      // Navigate back to previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message if sending fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reset email: $e')),
      );
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  // Clean up resources when widget is removed
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: SafeArea(
        child: Padding(
          padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon:Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                     SizedBox(height: 10),
                     Text(
                      "Please enter your email to reset the password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center, // Ensure text wraps nicely
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF3498DB),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              // Reset Password Button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3498DB),
                        Color(0xFF1C5175),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black, // Softer shadow color
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      textStyle:TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isLoading ? null : _sendPasswordResetEmail,// Disable when loading
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)// Show loading indicator
                        : Text("Reset Password"),// Show button text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}