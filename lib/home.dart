import 'package:flutter/material.dart';
import 'package:pendana/chats.dart';
import 'package:pendana/profile.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.name,
    required this.phone,
    required this.password,
    required this.age,
    required this.gender,
    required this.likes,
  });

  final String name;
  final String phone;
  final String password;
  final int age;
  final String gender;
  final String likes;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  // final List<Widget> _pages = [
  //   ChatPage(),
  //   Center(child: Text("Profile")),
  //   Center(child: Text("Settings")),
  // ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ChatPage(),
      const Profile(),
      const Center(child: Text("Settings Page")),
    ];
  }

  Widget _profilePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${widget.name}"),
          Text("Phone: ${widget.phone}"),
          Text("Age: ${widget.age}"),
          Text("Gender: ${widget.gender}"),
          Text("Likes: ${widget.likes}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
