import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserDataService {
  final currentUser = FirebaseAuth.instance.currentUser;

  final List<AppUser> mockUsers = [
    AppUser(
      firebaseUID: 'user1',
      name: 'Марко Петров',
      photoURL: 'https://example.com/photos/marko_petrov.jpg',
      email: 'marko.petrov@example.com',
    ),
    AppUser(
      firebaseUID: 'user2',
      name: 'Елена Стојановска',
      photoURL: 'https://example.com/photos/elena_stojanovska.jpg',
      email: 'elena.stojanovska@example.com',
    ),
    AppUser(
      firebaseUID: 'user3',
      name: 'Иван Јованов',
      photoURL: 'https://example.com/photos/ivan_jovanov.jpg',
      email: 'ivan.jovanov@example.com',
    ),
    AppUser(
      firebaseUID: 'user4',
      name: 'Ана Димитрова',
      photoURL: 'https://example.com/photos/ana_dimitrova.jpg',
      email: 'ana.dimitrova@example.com',
    ),
    AppUser(
      firebaseUID: 'user5',
      name: 'Стефан Николов',
      photoURL: 'https://example.com/photos/stefan_nikolov.jpg',
      email: 'stefan.nikolov@example.com',
    ),
  ];

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

  List<AppUser> getAllUsers() {
    final currentAppUser = getCurrentUser();
    return [...mockUsers, currentAppUser];
  }
}