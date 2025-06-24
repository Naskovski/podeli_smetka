import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserDataService {
  final currentUser = FirebaseAuth.instance.currentUser;

  AppUser getCurrentUser() {
    if (currentUser != null) {
      return AppUser(
        firebaseUID: currentUser!.uid,
        name: currentUser?.displayName ?? "Anonymous",
        photoURL: currentUser?.photoURL ?? "",
        email: currentUser?.email ?? "",
      );
    }
    return AppUser(firebaseUID: "", name: "", photoURL: "", email: "");
  }

  Future<AppUser?> getPublicInfoByEmail(String email) async {
    final doc = await FirebaseFirestore.instance
        .collection('userData')
        .doc(email)
        .collection('docRef')
        .doc('profile')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      return AppUser(
        firebaseUID: data['firebaseUID'] ?? '',
        name: data['name'] ?? '',
        photoURL: data['photoURL'] ?? '',
        email: data['email'] ?? email,
      );
    }

    return null;
  }
}