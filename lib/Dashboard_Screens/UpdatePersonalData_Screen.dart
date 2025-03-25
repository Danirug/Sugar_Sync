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
              SizedBox(height: 30),
              _buildUpdateButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      //bottomNavigationBar: _buildBottomNavigationBar(),
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
              borderSide: BorderSide.none)
      ),
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
          onPressed: () {
            // Add your update logic here
          },
          child: const Text("Update"),
        ),
      ),
    );
  }

  /*Widget _buildBottomNavigationBar(){
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Insights"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      currentIndex: 2,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        // Add navigation logic if needed

      },
    );
  }*/


}
