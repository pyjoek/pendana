import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/pages/home.dart';

class General extends StatefulWidget {
  final userId; 

  const General({super.key, required this.userId});

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  final PageController _pageController = PageController();
  final TextEditingController likesController = TextEditingController();

  List<String> availableLikes = [
    "Music",
    "Sports",
    "Travel",
    "Movies",
    "Reading",
    "Cooking",
    "Gaming",
    "Fitness"
  ];

  Set<String> selectedLikes = {};
  DateTime? selectedDate;
  String purpose = '';
  // final addr = "10.0.2.2:8000/api";
  final addr = "127.0.0.1:8000/api";
  bool _loading = false;

  void validateAndNext() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth")),
      );
      return;
    }

    int age = DateTime.now().year - selectedDate!.year;
    if (DateTime.now().month < selectedDate!.month ||
        (DateTime.now().month == selectedDate!.month &&
            DateTime.now().day < selectedDate!.day)) {
      age--;
    }

    if (age < 18 || age > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Age must be between 18 and 60")),
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> submitData(age) async {
    if (purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select gender and purpose")),
      );
      return;
    }

    final payload = {
      "user_id": widget.userId,
      "dob": selectedDate?.toIso8601String(), // backend expects a date
      "purpose": purpose,
      "interests": selectedLikes.toList(), // backend must allow array
    };
    print(payload);

    setState(() {
      _loading = true;
    });

    try {
      // Combine selected likes + custom input
      List<String> interests = selectedLikes.toList();
      if (likesController.text.isNotEmpty) {
        interests.add(likesController.text);
      }

      final response = await http.post(
        Uri.parse("http://$addr/user_general"), // add /api if your Laravel uses it
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home(userId: widget.userId)),
          (Route<dynamic> route) => false, // removes all previous routes
        );
      } else {
          try {
            final data = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${data['message']}")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unexpected error: ${response.body}")),
            );
          }
        }
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }


    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime minDate = DateTime(now.year - 60, now.month, now.day);
    DateTime maxDate = DateTime(now.year - 18, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("General Information"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: DOB
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Select your date of birth",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.pink),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumDate: minDate,
                    maximumDate: maxDate,
                    initialDateTime: maxDate,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: validateAndNext,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),

          // Step 3: Purpose
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Purpose of Joining",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.pink),
                ),
                const SizedBox(height: 20),
                RadioListTile(
                  title: const Text("Serious Relationship"),
                  value: "Serious Relationship",
                  groupValue: purpose,
                  onChanged: (value) {
                    setState(() => purpose = value.toString());
                  },
                ),
                RadioListTile(
                  title: const Text("Friendship"),
                  value: "Friendship",
                  groupValue: purpose,
                  onChanged: (value) {
                    setState(() => purpose = value.toString());
                  },
                ),
                RadioListTile(
                  title: const Text("Dating"),
                  value: "Dating",
                  groupValue: purpose,
                  onChanged: (value) {
                    setState(() => purpose = value.toString());
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: prevPage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300),
                        child: const Text("Previous")),
                    ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink),
                        child: const Text("Next")),
                  ],
                )
              ],
            ),
          ),

          // Step 4: Likes
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What do you like?",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.pink),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableLikes.map((like) {
                    final isSelected = selectedLikes.contains(like);
                    return ChoiceChip(
                      label: Text(like),
                      selected: isSelected,
                      selectedColor: Colors.pink.shade300,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedLikes.add(like);
                          } else {
                            selectedLikes.remove(like);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: prevPage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300),
                        child: const Text("Previous")),
                    ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                if (selectedDate != null) {
                                  int age = DateTime.now().year - selectedDate!.year;
                                  if (DateTime.now().month < selectedDate!.month ||
                                      (DateTime.now().month == selectedDate!.month &&
                                          DateTime.now().day < selectedDate!.day)) {
                                    age--;
                                  }
                                  submitData(age);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please select your date of birth")),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Finish")),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
