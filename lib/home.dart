import 'package:flutter/material.dart';
import 'package:pendana/chats.dart';
import 'package:pendana/encounter.dart';
import 'package:pendana/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.userId});

  final int userId;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Encounter(currentUserId: widget.userId,), // 👀 Encounters
      const Center(child: Text("Likes Page")),      // ❤️ Likes
      ChatListPage(userId: widget.userId),                             // 💬 Chats
      const Profile(),                              // ⚙️ Settings/Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // ✅ allows 4+ items
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt), // 👥 Encounters
              label: "Encounters",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite), // ❤️ Likes
              label: "Likes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), // 💬 Chats
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings), // ⚙️ Settings
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
