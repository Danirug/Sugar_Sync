import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Details_Screen extends StatefulWidget {
  const Details_Screen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<Details_Screen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender; // To store dropdown value
  String? _selectedActivityLevel; // To store activity level


  final Map<String, double> _activityFactors = {
    'Sedentary (little/no exercise)': 1.2,
    'Light exercise (1-3 days/week)': 1.375,
    'Moderate exercise (3-5 days/week)': 1.55,
    'Heavy exercise (6-7 days/week)': 1.725,
    'Athlete (Twice per day intense training)': 1.9,
  };


  void _SaveDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final age = int.tryParse(_ageController.text.trim());
        final weight = double.tryParse(_weightController.text.trim());
        final height = double.tryParse(_heightController.text.trim());

        // Validate inputs
        if (_selectedGender == null ||
            _selectedActivityLevel == null ||
            age == null ||
            weight == null ||
            height == null ||
            age <= 0 ||
            weight <= 0 ||
            height <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all fields with valid values')),
          );
          return;
        }

        // Step 1: Calculate BMR using Mifflin-St Jeor formula
        double bmr;
        if (_selectedGender == 'Male') {
          bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
        } else {
          bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
        }

        // Step 2: Calculate TDEE by multiplying BMR by activity factor
        final activityFactor = _activityFactors[_selectedActivityLevel]!;
        final tdee = bmr * activityFactor;

        // Step 3: Estimate sugar intake (e.g., 10% of TDEE calories as sugar)
        // 1g of sugar = 4 calories, so sugar (g) = (TDEE * 0.10) / 4
        final targetSugar = (tdee * 0.10) / 4;

        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'gender': _selectedGender,
          'age': _ageController.text.trim(),
          'weight': _weightController.text.trim(),
          'height': _heightController.text.trim(),
          'activityLevel': _selectedActivityLevel,
          'targetSugar': targetSugar, // Save the calculated target sugar
          'updatedAt': FieldValue.serverTimestamp(),
        });


        Navigator.pushNamed(context, 'DashBoardScreen');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'Assets/DetailsScreen.png',
                  height: 350,
                ),
                SizedBox(height: 20),
                Text(
                  "Let's complete your profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: "Choose Gender",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  value: _selectedGender,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.directions_run),
                    hintText: "Activity Level",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _activityFactors.keys.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                  value: _selectedActivityLevel,
                ),

                SizedBox(height: 16),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: "Age",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.monitor_weight),
                          hintText: "Your Weight",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("KG"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.height),
                          hintText: "Enter your height",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("CM"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedGender != null &&
                          _selectedActivityLevel != null &&
                          _ageController.text.isNotEmpty &&
                          _weightController.text.isNotEmpty &&
                          _heightController.text.isNotEmpty) {
                        _SaveDetails();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}