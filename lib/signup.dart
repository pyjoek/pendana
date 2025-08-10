import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key, required this.name});

  final String name;

  @override
  State<SignUp> createState() => _SignUpState(name: name);
}

class _SignUpState extends State<SignUp> {
  _SignUpState({required this.name});

  double width = 0;

  double height = 0;
  final String name;

  final Color background = Color(0xFFFFF9F6);

  final phone = TextEditingController();
  bool _obscureText = true;
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_sharp),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: height * 0.04,),
                  Text("Welcome", style: TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 44
                    ),
                  ),
                  Text(widget.name.toUpperCase(), style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 34
                    ),
                  ),
                  SizedBox(height: height * 0.05,),
                  Container(
                    height: height * 0.15,
                    child: Image.asset('assets/logo.png'),
                  ),
                  Text("Add More details", style: TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 24
                    ),
                  ),
                  SizedBox(height: height * 0.06,),
                  SizedBox(
                      width: width * 0.7,
                    child: TextFormField(
                      controller: phone,
                    decoration: InputDecoration(
                      hintText: 'Your Phone Number',
                      filled: true,
                      fillColor: background,
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    ),
                  ),
                  ),
                  SizedBox(height: height * 0.07,),
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
                            _obscureText = !_obscureText; // toggle visibility
                          });
                        },
                      ),
                      hintText: 'Password',
                      filled: true,
                      fillColor: background,
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    ),
                  ),
                  ),
                  SizedBox(height: height * 0.07,),
                  InkWell(
                  onTap: () {
                        print("Name: $name \nPhone: ${phone.text} \nPassword: ${password.text}");
                      },
                  child: Text("Sign Up", style: TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 30, color: Color(0xFFE28A89)
                    )
                  ),
                )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}