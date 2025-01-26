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
              child: userCredential.value == '' || userCredential.value == null
                  ? Column(
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
                      userCredential.value =
                      await authService.signInWithGoogle();
                      if (userCredential.value != null) {
                        print(userCredential.value.user!.email);
                      }
                    },
                    child: Image.asset(
                      'assets/icons/ctn_w_google.png', // Ensure you have the Google logo as an asset
                      height: 50, // Set the desired height for the image
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User profile image
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    child: Image.network(
                      userCredential.value.user!.photoURL.toString(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display user name and email
                  Text(
                    userCredential.value.user!.displayName.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userCredential.value.user!.email.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Logout button
                  ElevatedButton(
                    onPressed: () async {
                      bool result = await authService.signOutFromGoogle();
                      if (result) userCredential.value = '';
                    },
                    child: const Text('Logout'),
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
