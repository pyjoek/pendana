import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Encounter extends StatefulWidget {
  final int currentUserId;
  const Encounter({super.key, required this.currentUserId});

  @override
  State<Encounter> createState() => _EncounterState();
}

class _EncounterState extends State<Encounter> {
  List<dynamic> users = [];
  final CardSwiperController controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final res = await http.get(Uri.parse("http://127.0.0.1:8000/api/encounters/${widget.currentUserId}"));
    print("hi");
    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
      });
    }
  }

  Future<void> sendAction(int userId, String action) async {
    // action = "like" or "dislike"
    await http.post(
      Uri.parse("http://127.0.0.1:8000/api/encounters/action"),
      body: {
        "user_id": userId.toString(),
        "action": action,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Encounters")),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CardSwiper(
              controller: controller,
              cardsCount: users.length,
              allowedSwipeDirection:
                  const AllowedSwipeDirection.only(left: true, right: true),
              onSwipe: (prevIndex, currentIndex, direction) {
                if (prevIndex == null) return true;

                final user = users[prevIndex];
                if (direction == CardSwiperDirection.right) {
                  // ✅ Like
                  sendAction(user["id"], "like");
                } else if (direction == CardSwiperDirection.left) {
                  // ❌ Dislike
                  sendAction(user["id"], "dislike");
                }
                return true;
              },
              cardBuilder: (context, index, percentX, percentY) {
                final user = users[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User Image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          child: user["photo"] != null
                              ? Image.network(
                                  user["photo"],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: const Center(child: Icon(Icons.person, size: 80)),
                                ),
                        ),
                      ),
                      // User Details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              user["name"] ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${user["age"] ?? "N/A"} years old",
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(user["bio"] ?? "No bio available"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
