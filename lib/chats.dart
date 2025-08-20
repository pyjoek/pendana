import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/findusers.dart';
import 'dart:convert';
import 'chatpage.dart';
import 'dart:async';


class ChatListPage extends StatefulWidget {
  final int userId;
  const ChatListPage({super.key, required this.userId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> chats = [];

  @override
  void initState() {
    super.initState();
    fetchChats();

    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchChats();
    });
  }

  Future<void> fetchChats() async {
    final res = await http.get(Uri.parse("http://127.0.0.1:8000/api/chats/${widget.userId}"));
    if (res.statusCode == 200) {
      setState(() {
        chats = jsonDecode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: true,
        ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final otherUserId = chat["other_user_id"].toString();
          final userName = chat["other_user_name"].toString();
          final lastMsg = chat["messages"][0]["message"];

          return ListTile(
            title: Text(userName),
            subtitle: Text(lastMsg),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    userId: widget.userId,
                    receiverId: int.parse(otherUserId),
                  ),
                ),
              );
            },
          );
        },
      ),

      // 🔹 Button to start a new chat
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FindUsersPage(currentUserId: widget.userId),
            ),
          );
        },
      ),
    );
  }
}
