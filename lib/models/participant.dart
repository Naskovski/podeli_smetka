import 'package:podeli_smetka/models/user_model.dart';

class Participant {
  final String email;
  final AppUser? user;

  Participant({
    required this.email,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'user': user?.toJson(),
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      email: json['email'],
      user: json['user'] != null ? AppUser.fromJson(json['user']) : null,
    );
  }

  String get displayName => user?.name ?? email;
}
