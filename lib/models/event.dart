import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podeli_smetka/models/invite.dart';
import 'package:podeli_smetka/models/participant.dart';
import 'package:podeli_smetka/models/user_model.dart';

import 'expense.dart';

enum EventStatus { active, completed }

class Event {
  String id;
  String name;
  String description;
  EventStatus status;
  DateTime date;
  String? location;
  Map<String, double>? locationCoordinates;
  List<Participant> participants;
  List<Expense> expenses;
  AppUser organizer;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.date,
    this.location,
    this.locationCoordinates,
    required this.participants,
    required this.expenses,
    required this.organizer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'date': date.toIso8601String(),
      'location': location,
      'locationCoordinates': locationCoordinates,
      'participants': participants.map((p) => p.toJson()).toList(),
      'invitedParticipantEmails': participants.where((p) => p.status == ParticipantStatus.invited).map((p) => p.email).toList(),
      'acceptedParticipantEmails': participants.where((p) => p.status == ParticipantStatus.accepted).map((p) => p.email).toList(),
      'declinedParticipantEmails': participants.where((p) => p.status == ParticipantStatus.declined).map((p) => p.email).toList(),
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
      'organizer': organizer.toJson(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: EventStatus.values.firstWhere((e) => e.name == json['status']),
      date: DateTime.parse(json['date']),
      location: json['location'],
      locationCoordinates: json['locationCoordinates'] != null
          ? Map<String, double>.from(json['locationCoordinates'])
          : null,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participant.fromJson(p))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>)
          .map((expenseJson) => Expense.fromJson(expenseJson))
          .toList(),
      organizer: AppUser.fromJson(json['organizer']),
    );
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      status: EventStatus.values.firstWhere((e) => e.name == data['status']),
      date: DateTime.parse(data['date']),
      location: data['location'],
      locationCoordinates: data['locationCoordinates'] != null
          ? Map<String, double>.from(data['locationCoordinates'])
          : null,
      participants: (data['participants'] as List<dynamic>)
          .map((p) => Participant.fromJson(p))
          .toList(),
      expenses: (data['expenses'] as List<dynamic>? ?? [])
          .map((e) => Expense.fromJson(e))
          .toList(),
      organizer: AppUser.fromJson(data['organizer']),
    );
  }

  Invite toInvite() {
    return Invite(
      id: id,
      event: this,
      invitee: organizer,
      sentAt: DateTime.now(),
      status: InviteStatus.pending,
    );
  }

}
