import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pendana/home.dart';

class General extends StatefulWidget {

  const General({
    super.key,
  });

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
  String gender = '';
  String purpose = '';

  /// Validate age and go to next page
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime minDate = DateTime(now.year - 60, now.month, now.day);
    DateTime maxDate = DateTime(now.year - 18, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("General Information"),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: Date of Birth
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Select your date of birth",
                  style: Theme.of(context).textTheme.titleLarge,
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
                  onPressed: validateAndNext,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),

          // Step 2: Gender
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your gender:",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                RadioListTile(
                  title: const Text("Male"),
                  value: "Male",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() => gender = value.toString());
                  },
                ),
                RadioListTile(
                  title: const Text("Female"),
                  value: "Female",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() => gender = value.toString());
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: prevPage,
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: nextPage,
                      child: const Text("Next"),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Step 4: Purpose
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Purpose of Joining",
                  style: Theme.of(context).textTheme.titleLarge,
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
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: nextPage,
                      child: const Text("Next"),
                    ),
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: likesController,
                  decoration: const InputDecoration(
                    labelText: "Other likes (optional)",
                    border: OutlineInputBorder(),
                  ),
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
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        int age = DateTime.now().year - selectedDate!.year;
                        if (DateTime.now().month < selectedDate!.month ||
                            (DateTime.now().month == selectedDate!.month &&
                                DateTime.now().day < selectedDate!.day)) {
                          age--;
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                      },
                      child: const Text("Finish"),
                    ),
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
