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
  List<dynamic> usergeneral = [];
  final CardSwiperController controller = CardSwiperController();
  // final url = "http://10.0.2.2:8000/api";
  final url = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse("${url}/encounters/${widget.currentUserId}"),
      );

      if (res.statusCode == 200) {
        setState(() {
          users = jsonDecode(res.body)[0];
          usergeneral = jsonDecode(res.body)[1];
          // print(usergeneral[]);
        });
      } else {
        print("Error fetching users: ${res.statusCode}");
      }
    } catch (e) {
      print("Exception in fetchUsers: $e");
    }
  }

  Future<void> sendAction(int targetId, String action) async {
    final actionUrl = Uri.parse("${url}/encounters/action");

    try {
      final response = await http.post(
        actionUrl,
        body: {
          'user_id': widget.currentUserId.toString(),
          'target_id': targetId.toString(),
          'action': action,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Action sent: $action to $targetId");
      } else {
        print("❌ Error sending action: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in sendAction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUsers = users.isNotEmpty;
    final cardCount = hasUsers ? users.length : 1;

    return Scaffold(
      appBar: AppBar(title: const Text("Encounters")),
      body: CardSwiper(
        controller: controller,
        cardsCount: cardCount,
        numberOfCardsDisplayed: 1,
        allowedSwipeDirection: const AllowedSwipeDirection.only(left: true, right: true),
        onSwipe: (prevIndex, currentIndex, direction) {
          if (!hasUsers) return true;

          final user = users[prevIndex];
          final usergen = usergeneral[prevIndex];
          if (direction == CardSwiperDirection.right) {
            sendAction(user["id"], "like");
          } else if (direction == CardSwiperDirection.left) {
            sendAction(user["id"], "dislike");
          }

          setState(() {
            users.removeAt(prevIndex);
          });

          return true;
        },
        cardBuilder: (context, index, percentX, percentY) {
          if (!hasUsers) {
            // 🔹 Always show this card when list is empty
            return Card(
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  "No more users 😢",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final user = users[index];
          final usergen = usergeneral[index];
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  child: Row(
                    children: [
                      Icon(Icons.close_outlined, color: Colors.red,),
                      Spacer(),
                      Column(
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
                          "${usergen['dob'] ?? "N/A"} years old",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(usergen["bio"] ?? "No bio available"),
                      ],
                    ),
                      Spacer(),
                      Icon(Icons.heart_broken, color: Colors.green,),
                    ]
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
