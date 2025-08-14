import 'package:flutter/material.dart';
import 'package:pendana/login.dart';
import 'package:pendana/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() async {

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
        body: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: height * 0.2,),
                Text("PENDANA", style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 54
                  ),
                ),
                SizedBox(height: height * 0.08,),
                Container(
                  height: height * 0.15,
                  child: Image.asset('assets/logo.png'),
                ),
                SizedBox(height: height * 0.1,),
                Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Container(
                        child: Center(child: Text("SIGN UP", style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 20, color: Colors.white
                        ))),
                        width: width * 0.9,
                        height: height * 0.06,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFE28A89)
                        ),
                      ),
                    );
                  }
                ),
              SizedBox(height: height * 0.04,),
              Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
                        print('logging....');
                      },
                      child: Text(
                        "ALREADY HAVE AN ACCOUNT?",
                        style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
