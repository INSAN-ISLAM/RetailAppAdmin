import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:retailadminpanel/Widget/AppEevatedButton.dart';
import '../Widget/AppTextField.dart';
import 'AdminNavigationBarPage.dart';

class LogInScreen extends StatefulWidget {
  LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailETController = TextEditingController();
  final TextEditingController _passwordETController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const adminUID = "BlUktzurVDOqeekeWf4eaq13Kut1";

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: _emailETController.text,
        password: _passwordETController.text,
      );

      await FirebaseFirestore.instance.collection('admins').doc('milonc70@gmail.com').update({
        'token' : FieldValue.arrayUnion([await FirebaseMessaging.instance.getToken()]),
      });

      if (result.user!.uid == adminUID) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMainBottomNavBar()),
        );
      } else {
        _showErrorDialog("Unauthorized access. Only admin can log in.");
      }
    } catch (e) {
      _showErrorDialog("Error logging in: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Login Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    'Login to your account & start delivering.',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Color(0xFF6A7189),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextFieldWidget(
                  controller: _emailETController,
                  hintText: 'Enter Your Email',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter your valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextFieldWidget(
                  obscureText: _obscureText,
                  hintText: 'Enter Your Password',
                  controller: _passwordETController,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  validator: (value) {
                    if ((value?.isEmpty ?? true) || ((value?.length ?? 0) < 6)) {
                      return 'Enter a password with more than 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  height: 48,
                  width: 358,
                  color: Colors.blueGrey,
                  child: AppElevatedButton(
                    Color: Colors.blueGrey,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
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
