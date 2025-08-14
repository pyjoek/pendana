import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
    
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double width = 0;
  double height = 0;
  Color bg = Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bg,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: height * 0.15,),
                  Text("PENDANA", style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 44
                  ),
                ),
                  Container(
                    width: width * 0.8,
                    height: height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 8),
                        blurRadius: 10
                      )]
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.03,),
                        Text("Log In", style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 28, color: Colors.pink
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hint: Text("Email"),
                                  
                                ),
                              )
                            ],
                          ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }
}