import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement privacy policy navigation
              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
            },
          ),

          const Divider(),

          // Log Out
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Log out'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement logout functionality
              // Example: _showLogoutConfirmationDialog(context);
            },
          ),

          const Divider(),

          // Theme Toggle
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            value: false,
            onChanged: (bool value) {
              // TODO: Implement theme switching
              // Example: Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  // Optional: Logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () {
                // TODO: Implement actual logout logic
                // Example: AuthService().logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}