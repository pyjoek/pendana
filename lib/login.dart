import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return; // User cancelled

      // Get basic profile info
      print('Name: ${account.displayName}');
      print('Email: ${account.email}');
      print('Photo: ${account.photoUrl}');

      // Send account info to your backend to create/log in the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${account.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _startPhoneAuth(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PhoneAuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton.icon(
            icon: Icon(Icons.login),
            label: Text('Sign in with Google'),
            onPressed: () => _signInWithGoogle(context),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(Icons.phone),
            label: Text('Sign in with Phone'),
            onPressed: () => _startPhoneAuth(context),
          ),
        ]),
      ),
    );
  }
}

class PhoneAuthPage extends StatefulWidget {
  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _serverCode; // Store verification code from your backend

  void _sendCode() async {
    // Here you’d call your backend API to send an SMS
    // For demo purposes:
    setState(() => _serverCode = "123456");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code sent to ${_phoneController.text}')),
    );
  }

  void _verifyCode() {
    if (_codeController.text.trim() == _serverCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone verified successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone (+255...)')),
          ElevatedButton(onPressed: _sendCode, child: Text('Send code')),
          TextField(controller: _codeController, decoration: InputDecoration(labelText: 'Enter code')),
          ElevatedButton(onPressed: _verifyCode, child: Text('Verify')),
        ]),
      ),
    );
  }
}
