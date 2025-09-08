import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pendana/auth/forgot.dart';
import 'dart:convert';
import 'package:pendana/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pendana/auth/signup.dart';

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
  final Color background = const Color(0xFFFFF9F6);

  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscureText = true;
  bool _loading = false;

  Future<void> loginUser() async {
  final emailText = email.text.trim();
  final passText = password.text;
  // final apiBase = 'http://10.0.2.2:8000/api';
  final apiBase = 'http://127.0.0.1:8000/api';

  if (emailText.isEmpty || passText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter email and password")),
    );
    return;
  }
  

  setState(() => _loading = true);

  try {
    final url = Uri.parse('$apiBase/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailText, 'password': passText}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final accessToken = body['access_token'];
      final user = body['user'];
      final userId = body['userId'];
      final userGeneral = body['userGeneral'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_name', user['name'] ?? '');
      await prefs.setString('gender', user['gender'] ?? '');
      await prefs.setString('user_profile_picture', userGeneral['profile_picture'] ?? '');
      await prefs.setInt('userId', userId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Home(userId: userId),
        ),
      );

    } else {
      String message = 'Login failed';
      try {
        final body = jsonDecode(response.body);
        message = body['error'] ?? body['message'] ?? message;
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network error: $e")));
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: height * 0.15),
                Text(
                  "PENDANA",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 44),
                ),
                Container(
                  width: width * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(3, 8),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(height: height * 0.04),

                      // Email Field
                      SizedBox(
                        width: width * 0.7,
                        child: TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            hintText: 'Your Email',
                            filled: true,
                            fillColor: background,
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.04),

                      // Password Field
                      SizedBox(
                        width: width * 0.7,
                        child: TextFormField(
                          controller: password,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            hintText: 'Password',
                            filled: true,
                            fillColor: background,
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.06),

                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => ForgotPassword(),
                      //       ),
                      //     );
                      //   },
                      //   child: Container(
                      //     width: double.infinity,
                      //     padding: EdgeInsets.symmetric(vertical: 15),
                      //     child: Center(
                      //       child: Text(
                      //         "Forgot Password?!",
                      //         style: TextStyle(
                      //             color: Colors.pink,
                      //             fontSize: 15,
                      //             fontWeight: FontWeight.w400),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: _loading ? null : loginUser,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: _loading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Sign In",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Center(
                            child: Text(
                              "Create New Account!",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
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
