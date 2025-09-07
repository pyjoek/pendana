import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.userId});
  final int userId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";
  Map<String, dynamic> users = {};
  Map<String, dynamic> usergeneral = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final response = await http.get(
      Uri.parse("$url/profile/${widget.userId}")
    );

    if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body)[0];
          usergeneral = json.decode(response.body)[1];
        });
      } else {
        print("Error fetching users: ${response.statusCode}");
      }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse("${url}/logout"),
      headers: {'Content-Type': 'application/json'},
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              // CircleAvatar(
              //   radius: 80,
              //   backgroundImage: profileImage != null
              //       ? FileImage(profileImage! as File)
              //       : AssetImage(
              //           gender == "male"
              //               ? "assets/male.jpg"
              //               : "assets/female.png",
              //         ) as ImageProvider,
              // ),
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage("http://127.0.0.1:8000/storage/${usergeneral['profile_picture']}"),
                // backgroundImage: AssetImage("assets/male.jpg"),
              ),

              const SizedBox(height: 20),

              // User Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoRow("Name", users['name'] ?? ""),
                      const Divider(),
                      infoRow("Email", users['email'] ?? ""),
                      const Divider(),
                      infoRow("Bio", usergeneral['bio'] ?? ""),
                      const Divider(),
                      infoRow("Gender", users['gender'] ?? ""),
                      const Divider(),
                      infoRow("Age", usergeneral['dob'] ?? ""),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 30),

              // Logout Button
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
