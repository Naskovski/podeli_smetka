import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserListItem extends StatelessWidget {
  final AppUser? user;
  final String? email;
  final double size;
  final String additionalText;

  const UserListItem({
    super.key,
    this.user,
    this.email,
    this.size = 24,
    this.additionalText = "",
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? email ?? "Unknown";
    final displayPhoto = user?.photoURL ?? 'https://via.placeholder.com/150';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(displayPhoto),
        radius: size,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
      subtitle: additionalText.isNotEmpty ? Text(additionalText) : null,
    );
  }
}
