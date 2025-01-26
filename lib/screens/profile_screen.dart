import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профил'),
      ),
      body: user == null
          ? const Center(child: Text('No user logged in.'))
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
            const SizedBox(height: 20),
            Text(user.displayName ?? 'Anonymous',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(user.email ?? 'No Email'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                service.signOutFromGoogle();
              },
              child: const Text('Одјави се'),
            ),
          ],
        ),
      ),
    );
  }
}
