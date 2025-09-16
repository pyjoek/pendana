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
  bool isLoading = true;
  final url = "http://127.0.0.1:8000/api";
  // final url = "http://10.0.2.2:8000/api"; // for Android emulator

  @override
  void initState() {
    super.initState();
    fetchUsersLikedMe();
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  Future<void> fetchUsersLikedMe() async {
    try {
      final res = await http.get(
        Uri.parse("$url/encounters/liked-me/${widget.userId}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          usersLikedMe = data; // store list of users with their usergeneral
          isLoading = false;
        });
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
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // two items per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: usersLikedMe.length,
                  itemBuilder: (context, index) {
                    final user = usersLikedMe[index];
                    final usergeneral = user['usergeneral'];

                    return GestureDetector(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: usergeneral['profile_picture'] != null
                                  ? NetworkImage(
                                      "http://127.0.0.1:8000/storage/${usergeneral['profile_picture']}",
                                    )
                                  : const AssetImage("assets/images/placeholder.png")
                                      as ImageProvider,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user['name'] ?? "Unknown",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${calculateAge(usergeneral['dob'])} yrs • ${usergeneral['gender'] ?? ''}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            const Icon(Icons.favorite, color: Colors.pink),
                          ],
                        ),
                      ),
                      onTap: () {
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
                    );
                  },
                ),
    );
  }
}
