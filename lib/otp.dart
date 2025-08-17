import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pendana/general.dart';

class OtpPage extends StatefulWidget {
  final String email; // email passed from signup page

  const OtpPage({super.key, required this.email});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String otpp = '';
  String userId = '';

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:8000/api/verify-otp"); 
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "otp": otpController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      userId = body['user'];
      final ottp = body['otp'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['message'] ?? 'Verified!')),
      );
      // ✅ Navigate to Login page after success
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      String errorMsg = 'Verification failed';
      try {
        final body = jsonDecode(response.body);
        errorMsg = body['error'] ?? body['message'] ?? errorMsg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820), // same dark background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101820),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "We’ve sent a 6-digit code to\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // OTP Input
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter OTP",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Verify Button
                ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946), // same red accent
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    // TODO: Resend OTP API
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(color: Color(0xFFE63946)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                     Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => General(userId: userId), // <-- go to General
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Color(0xFFE63946)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
