import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserListItem extends StatelessWidget {
  final AppUser user;
  final double size;
  final String additionalText;

  const UserListItem({super.key, required this.user, this.size = 24, this.additionalText = ""});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL),
        radius: size,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
      subtitle: additionalText != "" ? Text(additionalText): null,
    );
  }
}
