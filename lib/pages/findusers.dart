import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatpage.dart';

class FindUsersPage extends StatefulWidget {
  final int currentUserId;
  const FindUsersPage({super.key, required this.currentUserId});

  @override
  State<FindUsersPage> createState() => _FindUsersPageState();
}

class _FindUsersPageState extends State<FindUsersPage> {
  List<dynamic> users = [];
  final url = "http://10.0.2.2:8000/api";
  // final url = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final res = await http.get(Uri.parse("${url}/users/${widget.currentUserId}"));
    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Users")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user["name"] ?? "User ${user['id']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    userId: widget.currentUserId,
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
