import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/UpdatePersonalData_Screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _firstName = 'User';
  String _lastName = '';
  String _height = '';
  String _weight = '';
  String _sugarIntake = '';

  @override
  void initState(){
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
          _firstName = data['firstName'] ?? 'User';
          _lastName = data['lastName'] ?? '';
          _height = data['height']?.toString() ?? 'N/A';
          _weight = data['weight']?.toString() ?? 'N/A';
          _sugarIntake = data['targetSugar']?.toStringAsFixed(0) ?? 'N/A';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFCCF4E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title:Text(
          "Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
            padding:EdgeInsets.only(right: 16),
            child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.deepOrange,// Add your profile picture asset
            ),
          ),
        ],
      ),
      body: Padding(
        padding:EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Profile Card
            SizedBox(height: 20),
            Container(
              padding:  EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       SizedBox(width: 12),
                       Expanded(
                        child: Text(
                          "$_firstName $_lastName",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'UpdateScreen');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text("Edit", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Info Cards Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard("$_height cm", "Height"),
                      _buildInfoCard("$_weight kg", "Weight"),
                      _buildInfoCard("$_sugarIntake g", "Sugar intake"),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // List Sections
            _buildListItem(context,Icons.person_outline, "Personal Data"),
            _buildDivider(),
            _buildListItem(context,Icons.pie_chart_outline, "Activity History"),
            _buildDivider(),
            _buildListItem(context,Icons.settings_outlined, "Settings"),
            _buildDivider()
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade300, Colors.blue]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            label,
            style:  TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextButton(
        onPressed: () {
          if (title == "Personal Data") {
            Navigator.pushNamed(context, 'UpdateScreen');
          } else if (title == "Activity History") {
            Navigator.pushNamed(context, 'InsightsScreen');
          } else if (title == "Settings") {
            Navigator.pushNamed(context, 'SettingScreen');
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, size: 24, color: Colors.black54),
          ],
        ),
      ), // Moved child inside TextButton
    );
  }
}

Widget _buildDivider() {
  return Divider(
    thickness: 2,
    color: Colors.black,
  );
}
