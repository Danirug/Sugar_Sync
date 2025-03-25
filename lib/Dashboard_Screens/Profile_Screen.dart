import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/UpdatePersonalData_Screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
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
                          "Stefani Wong",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                      _buildInfoCard("", "Height"),
                      _buildInfoCard("", "Weight"),
                      _buildInfoCard("", "Sugar intake"),
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
