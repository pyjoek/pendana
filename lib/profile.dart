import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/logout'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
      // Optionally, you can clear user data or navigate to login screen
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Handle logout failure if needed
      print('Logout failed: ${response.statusCode}');
    }
    // You can also navigate to the login screen if needed
    // For now, just print a message
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()), // Replace Profile() with your Login screen widget
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                child: Text("R"),
                radius: 20,
              ),
              InkWell(
                onTap: () {
                  // Navigate to edit profile page
                  logout();
                },
                child: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}