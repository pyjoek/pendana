import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.name, required this.phone, required this.password, required this.age, required this.gender, required this.likes, });

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble))
          ]
          ),
      )
    );
  }
}