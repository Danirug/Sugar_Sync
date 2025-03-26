import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/MainDashboard_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Insights_Screen.dart';

class Update_Screen extends StatefulWidget {
  const Update_Screen({super.key});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<Update_Screen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController targetSugarController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          weightController.text = data['weight']?.toString() ?? '';
          heightController.text = data['height']?.toString() ?? '';
          targetSugarController.text = data['targetSugar']?.toString() ?? '';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('First name and last name are required')),
      );
      return;
    }

    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final targetSugar = double.tryParse(targetSugarController.text.trim());

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid weight and height')),
      );
      return;
    }

    if (targetSugar == null || targetSugar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid target sugar amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'weight': weight,
        'height': height,
        'targetSugar': targetSugar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard_Screen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4f7E4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Update Personal Data",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _buildTextField(
                firstNameController,
                "First Name",
                Icons.person,
              ),
              SizedBox(height: 15),
              _buildTextField(
                lastNameController,
                "Last Name",
                Icons.person,
              ),
              SizedBox(height: 15),
              _buildTextField(
                weightController,
                "Weight",
                Icons.monitor_weight,
              ),
              SizedBox(height: 15),
              _buildTextField(
                heightController,
                "Height",
                Icons.height,
              ),

              SizedBox(height: 15),
              _buildTextField(
                targetSugarController,
                "Target Sugar (g)",
                Icons.food_bank_rounded,
              ),
              // *** END UPDATED ***
              SizedBox(height: 30),
              _buildUpdateButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none)),
      keyboardType: hintText == "Weight" || hintText == "Height" || hintText == "Target Sugar (g)"
          ? TextInputType.number
          : TextInputType.text,
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3498DB),
              Color(0xFF1C5175),
            ],
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 5,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: _isLoading ? null : _updateUserData,
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.black)
              : Text("Update"),
        ),
      ),
    );
  }
}