import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g21285889_daniru_gihen/Onborading_Screens/Welcome_Screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  //Logout logic
  Future<void> _logout(BuildContext context) async{
    try{
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Welcome_Screen()),
          (Route<dynamic> route) => false,
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFCCF4E6),
      appBar: AppBar(
        title:  Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Privacy Policy
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            trailing:Icon(Icons.chevron_right),
            onTap: () {

            },
          ),

          Divider(),

          // Log Out
          ListTile(
            leading: Icon(Icons.logout_outlined),
            title: Text('Log out'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _showLogoutDialog(context);

            },
          ),
        ],
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child:Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Log Out'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }
}