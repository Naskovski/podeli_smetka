import 'package:podeli_smetka/models/user_model.dart';
import 'package:podeli_smetka/models/user_paid.dart';

enum ExpenseStatus { pending, paid, split }

class Expense {
  String id;
  String name;
  String description;
  double amount;
  AppUser createdBy;
  DateTime createdAt;

  Expense({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      createdBy: AppUser.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
