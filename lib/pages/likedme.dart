import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pendana/pages/chatpage.dart';

class LikedMePage extends StatefulWidget {
  const LikedMePage({super.key, required this.userId});
  final int userId;

  @override
  State<LikedMePage> createState() => _LikedMePageState();
}

class _LikedMePageState extends State<LikedMePage> {
  List<dynamic> usersLikedMe = [];
  Map<String, dynamic> usergeneral = {};
  bool isLoading = true;
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();
    fetchUsersLikedMe();
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime today = DateTime.now();

    int age = today.year - dob.year;

    // If birthday hasn’t occurred yet this year, subtract 1
    if (today.month < dob.month || 
      (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }


  Future<void> fetchUsersLikedMe() async {
    try {
      final res = await http.get(
        Uri.parse("${url}/encounters/liked-me/${widget.userId}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          usersLikedMe = data[0];
          usergeneral = data[1];
          isLoading = false;
        });

        print(usergeneral['dob']);
      } else {
        print("Failed to fetch users who liked me: ${res.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching users who liked me: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("People Who Liked Me 💌"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usersLikedMe.isEmpty
              ? const Center(child: Text("Nobody has liked you yet."))
              : ListView.builder(
                  itemCount: usersLikedMe.length,
                  itemBuilder: (context, index) {
                    final user = usersLikedMe[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage("http://127.0.0.1:8000/storage/${usergeneral['profile_picture']}"),
                        ),
                        title: Text(user['name'] ?? "Unknown"),
                        subtitle: Text(
                          "${calculateAge(usergeneral['dob'])} yrs • ${user['gender'] ?? ''}",
                        ),
                        trailing: const Icon(Icons.favorite, color: Colors.pink),
                        onTap: () {
                            // Later: open profile or start chat
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                              userId: widget.userId,
                              receiverId: user['id'],
                              otherUserName: user['name'],
                              ),
                            ),
                            );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}