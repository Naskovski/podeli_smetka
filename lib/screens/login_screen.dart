import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podeli_smetka/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier userCredential = ValueNotifier('');
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: userCredential,
        builder: (context, value, child) {
          return Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hero Title
                    const Hero(
                      tag: 'login-hero-title',
                      child: Text(
                        'Подели сметка',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Google Login Button (only image)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        userCredential.value = await authService.signInWithGoogle();
                        if (userCredential.value != null) {
                          Navigator.pushReplacementNamed(context, '/app');
                        }
                      },
                      child: Image.asset(
                        'assets/icons/ctn_w_google.png',
                        height: 50,
                      ),
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}
