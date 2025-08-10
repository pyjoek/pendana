import 'package:flutter/material.dart';

class General extends StatefulWidget {
  final String name;
  final String phone;
  final String password;

  const General({
    super.key,
    required this.name,
    required this.phone,
    required this.password,
  });

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  final PageController _pageController = PageController();
  final TextEditingController ageController = TextEditingController();
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

    // Track which likes are selected
  Set<String> selectedLikes = {};

  String gender = '';

  void nextPage() {
    if (_pageController.page != null &&
        _pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (_pageController.page != null &&
        _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("General Information"),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: Age
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "What's your age?",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Enter your age",
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: nextPage,
                    child: const Text("Next"),
                  ),
                )
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

          // Step 3: Likes
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

                // Optional: also keep the TextField for custom likes
                TextField(
                  controller: likesController,
                  decoration: const InputDecoration(
                    labelText: "Other likes (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                // Wrap widget to show selectable chips/buttons for likes
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
                        print("Name: ${widget.name}");
                        print("Phone: ${widget.phone}");
                        print("Password: ${widget.password}");
                        print("Age: ${ageController.text}");
                        print("Gender: $gender");
                        print("Selected Likes: $selectedLikes");
                        print("Other Likes: ${likesController.text}");
                      },
                      child: const Text("Finish"),
                    ),
                  ],
                )
              ],
            ),
          ),


          // Padding(
          //   padding: const EdgeInsets.all(20),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "What do you like?",
          //         style: Theme.of(context).textTheme.titleLarge,
          //       ),
          //       const SizedBox(height: 20),
          //       TextField(
          //         controller: likesController,
          //         decoration: const InputDecoration(
          //           labelText: "Enter your likes",
          //           border: OutlineInputBorder(),
          //         ),
          //       ),
          //       const Spacer(),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           ElevatedButton(
          //             onPressed: prevPage,
          //             child: const Text("Previous"),
          //           ),
          //           ElevatedButton(
          //             onPressed: () {
          //               print("Name: ${widget.name}");
          //               print("Phone: ${widget.phone}");
          //               print("Password: ${widget.password}");
          //               print("Age: ${ageController.text}");
          //               print("Gender: $gender");
          //               print("Likes: ${likesController.text}");
          //             },
          //             child: const Text("Finish"),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
