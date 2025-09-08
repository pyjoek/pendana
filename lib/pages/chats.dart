import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/pages/findusers.dart';
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
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";
  Timer? _chatTimer;

@override
void initState() {
  super.initState();
  fetchChats();
  _chatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    fetchChats();
  });
}

@override
void dispose() {
  _chatTimer?.cancel(); // 🔹 Prevent memory leaks
  super.dispose();
}


  Future<void> fetchChats() async {
  try {
    final res = await http.get(Uri.parse("${url}/chats/${widget.userId}"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (!mounted) return; // ✅ prevent setState after dispose

      setState(() {
        chats = data;
      });
    }
  } catch (e) {
    print("Error fetching chats: $e");
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
          final isRead = chat["messages"][0]["is_read"] ?? true;


          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Text(
                userName[0].toUpperCase()
                ),
              ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(
              lastMsg,
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    userId: widget.userId,
                    receiverId: int.parse(otherUserId),
                    otherUserName: userName,
                  ),
                ),
              ).then((_) {
                fetchChats();
              });
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
          ).then((_) {
            fetchChats(); // 🔹 Refresh when coming back
          });
        },
      ),
    );
  }
}
