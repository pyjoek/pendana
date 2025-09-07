import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name;
  String? email;
  String profileImage = "profiles/logo.png";
  String? gender;
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("user_name") ?? "Guest User";
      email = prefs.getString("user_email") ?? "guest@example.com";
      profileImage = prefs.getString("user_profile_picture") ?? "";
      gender = prefs.getString('gender');
    });
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
    // final avatarLetter = name != null && name!.isNotEmpty
    //     ? name![0].toUpperCase()
    //     : "U";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
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
                backgroundImage: NetworkImage('http://127.0.0.1:8000/storage/$profileImage'),
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
                      infoRow("Name", name ?? ""),
                      const Divider(),
                      infoRow("Email", email ?? ""),
                      const Divider(),
                      // infoRow("Bio", bio ?? ""),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                      infoRow("Gender", gender ?? ""),
                      const Divider(),
                      // infoRow("Age", age ?? ""),
                    ],
                  ),
                ),
              ),

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
