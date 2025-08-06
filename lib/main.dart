import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  if (Platform.isAndroid || Platform.isIOS) {
    print("Running on mobile");
  } else {
    print("Not running on mobile. Splash won’t show.");
  }
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
    initialization();
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

    FlutterNativeSplash.remove(); // Remove native splash screen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendana',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pendana - Home'),
        ),
        body: Center(
          child: Text(
            'Welcome to Pendana ❤️',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
