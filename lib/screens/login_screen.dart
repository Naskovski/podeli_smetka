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
                  Image.asset(
                    'assets/images/podeli_smetka_banner_transparent_1024.png',
                    height: 150,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
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
              ),
            ),
          );
        },
      ),
    );
  }
}