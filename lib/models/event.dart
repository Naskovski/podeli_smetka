import 'package:flutter/foundation.dart';

import 'expense.dart';

enum EventStatus { active, completed }

class Event {
  String id;
  String name;
  String description;
  EventStatus status;
  DateTime date;
  String location;
  List<String> participants; // List of user UIDs
  List<Expense> expenses; // Embedded expenses
  String organizer; // UID of the event organizer

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.date,
    required this.location,
    required this.participants,
    required this.expenses,
    required this.organizer,
  });

  // Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': describeEnum(status),
      'date': date.toIso8601String(),
      'location': location,
      'participants': participants,
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
      'organizer': organizer,
    };
  }

  // Create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: EventStatus.values.firstWhere((e) => describeEnum(e) == json['status']),
      date: DateTime.parse(json['date']),
      location: json['location'],
      participants: List<String>.from(json['participants']),
      expenses: (json['expenses'] as List<dynamic>)
          .map((expenseJson) => Expense.fromJson(expenseJson))
          .toList(),
      organizer: json['organizer'],
    );
  }
}
