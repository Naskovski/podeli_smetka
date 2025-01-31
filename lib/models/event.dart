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
  List<AppUser> participants;
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
      'participants': participants.map((user) => user.toJson()).toList(),
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
          .map((userJson) => AppUser.fromJson(userJson))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>)
          .map((expenseJson) => Expense.fromJson(expenseJson))
          .toList(),
      organizer: AppUser.fromJson(json['organizer']),
    );
  }
}
