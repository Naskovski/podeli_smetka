import 'package:flutter/foundation.dart';

enum ExpenseStatus { pending, paid, split }

class Expense {
  String id;
  String name;
  String description;
  ExpenseStatus status;
  List<String> paidBy; // UIDs of users who paid this expense
  double amount;
  String createdBy; // UID of the user who created the expense
  DateTime createdAt;

  Expense({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.paidBy,
    required this.amount,
    required this.createdBy,
    required this.createdAt,
  });

  // Convert Expense to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': describeEnum(status),
      'paidBy': paidBy,
      'amount': amount,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Expense from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ExpenseStatus.values.firstWhere((e) => describeEnum(e) == json['status']),
      paidBy: List<String>.from(json['paidBy']),
      amount: (json['amount'] as num).toDouble(),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
