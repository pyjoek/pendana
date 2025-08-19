import 'package:flutter/material.dart';
import 'package:pendana/chatpage.dart';

class ChatListPage extends StatelessWidget {
  final List<Map<String, dynamic>> chats = [
    {"id": 1, "name": "Alice", "lastMessage": "Hey, how are you?"},
    {"id": 2, "name": "Bob", "lastMessage": "See you tomorrow!"},
    {"id": 3, "name": "Charlie", "lastMessage": "Let's meet up."},
  ];

  ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(chat["name"][0]), // First letter
            ),
            title: Text(chat["name"]),
            subtitle: Text(chat["lastMessage"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    userId: chat["id"],
                    userName: chat["name"],
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
