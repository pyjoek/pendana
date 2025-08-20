import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pendana/chatpage.dart';

class LikedMePage extends StatefulWidget {
  final int userId; // current logged-in user id

  const LikedMePage({super.key, required this.userId});

  @override
  State<LikedMePage> createState() => _LikedMePageState();
}

class _LikedMePageState extends State<LikedMePage> {
  List<dynamic> usersLikedMe = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsersLikedMe();
  }

  Future<void> fetchUsersLikedMe() async {
    try {
      final res = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/encounters/liked-me/${widget.userId}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          usersLikedMe = data;
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
              : ListView.builder(
                  itemCount: usersLikedMe.length,
                  itemBuilder: (context, index) {
                    final user = usersLikedMe[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: user['photo'] != null
                              ? NetworkImage(user['photo'])
                              : null,
                          child: user['photo'] == null
                              ? Text(user['name'][0].toUpperCase())
                              : null,
                        ),
                        title: Text(user['name'] ?? "Unknown"),
                        subtitle: Text(
                          "${user['age'] ?? 'N/A'} yrs • ${user['gender'] ?? ''}",
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
