import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 25,
        ),
      ),
      actions: [
        if (user?.photoURL != null)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            ),
          )
        else
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle, size: 36),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
