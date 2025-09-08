import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final int userId;      // current logged-in user
  final int receiverId;  // the person you’re chatting with
  final String otherUserName;

  const ChatPage({super.key, required this.userId, required this.receiverId, required this.otherUserName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";

  Timer? _timer;

@override
void initState() {
  super.initState();
  _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    fetchMessages();
  });
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}


  Future<void> fetchMessages() async {
    final res = await http.get(Uri.parse("${url}/messages/${widget.userId}/${widget.receiverId}"));
    if (res.statusCode == 200) {
      setState(() {
        messages = jsonDecode(res.body);
      });
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final res = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_id": widget.userId,
        "receiver_id": widget.receiverId,
        "message": _controller.text.trim(),
      }),
    );

    if (res.statusCode == 201) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["sender_id"] == widget.userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
