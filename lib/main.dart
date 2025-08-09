import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  if (Platform.isAndroid || Platform.isIOS) {
    print("Running on mobile");
  } else {
    print("Not running on mobile. Splash won’t show.");
  }
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // initialization();
  }

  void initialization() async {
    print('Checking if splash should be shown...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('seenSplash') ?? false;

    if (!isFirstLaunch) {
      print('First time opening app...');
      await prefs.setBool('seenSplash', true);
      await Future.delayed(Duration(seconds: 3));
    } else {
      print('Not first launch. Skipping splash delay.');
    }

    // FlutterNativeSplash.remove(); // Remove native splash screen
  }

  final Color background = Color(0xFFFFF9F6);
  final name = TextEditingController();
  double width = 0;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor:background,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: height * 0.1,),
                  Text("Create", style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 64
                  ),),
                  Text("Account", style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 64
                  ),),
                  SizedBox(height: height * 0.04,),
                  Text("Sign up to find", style: TextStyle(
                    fontWeight: FontWeight.w300, fontSize: 34
                  ),),
                  Text("Your match!", style: TextStyle(
                    fontWeight: FontWeight.w300, fontSize: 34
                  ),),
                  SizedBox(height: height * 0.05,),
                  SizedBox(
                      width: width * 0.7,
                    child: TextFormField(
                      controller: name,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: background,
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    ),
                  ),
                  ),
                  SizedBox(height: 20,),
                  InkWell(
                    onTap: () => {print('hello ${name.text}')},
                    child: Container(
                      child: Center(child: Text("sign up", style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 30, color: Colors.white
                      ))),
                      width: width * 0.7,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xFFE28A89)
                      ),
                    ),
                  ),
                SizedBox(height: height * 0.2,),
                InkWell(
                  onTap: () => {print('logging....')},
                  child: Text("Log in", style: TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 30, color: Color(0xFFE28A89)
                    )
                  ),
                )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
