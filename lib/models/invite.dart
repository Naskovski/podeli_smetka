import 'package:podeli_smetka/models/event.dart';
import 'package:podeli_smetka/models/user_model.dart';

enum InviteStatus {
  pending, accepted, declined
}

class Invite {
  final String id;
  final Event event;
  final AppUser invitee;
  final DateTime sentAt;
  InviteStatus status;

  Invite({
    required this.id,
    required this.event,
    required this.invitee,
    required this.sentAt,
    this.status = InviteStatus.pending,
  });
}