import 'package:podeli_smetka/models/user_model.dart';

class Participant {
  final String email;
  final AppUser? user;
  var status = ParticipantStatus.invited;

  Participant({
    required this.email,
    this.user,
    this.status = ParticipantStatus.invited,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'user': user?.toJson(),
      'status': status.name,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      email: json['email'],
      user: json['user'] != null ? AppUser.fromJson(json['user']) : null,
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParticipantStatus.invited,
      ),
    );
  }

  String get displayName => user?.name ?? email;

  Participant updateStatus(ParticipantStatus newStatus) {
    return Participant(
      email: email,
      user: user,
      status: newStatus,
    );
  }
}

enum ParticipantStatus {
  invited,
  accepted,
  declined
}