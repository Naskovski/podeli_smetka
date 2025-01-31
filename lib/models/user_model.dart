class AppUser {
  String firebaseUID;
  String name;
  String photoURL;
  String email;

  AppUser({
    required this.firebaseUID,
    required this.name,
    required this.photoURL,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebaseUID': firebaseUID,
      'name': name,
      'photoURL': photoURL,
      'email': email,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      firebaseUID: json['firebaseUID'],
      name: json['name'],
      photoURL: json['photoURL'],
      email: json['email'],
    );
  }
}
