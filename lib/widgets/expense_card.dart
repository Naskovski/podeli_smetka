import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(expense.name),
        subtitle: Text('${expense.description} - \$${expense.amount.toStringAsFixed(2)}'),
        trailing: Text(
          expense.status == ExpenseStatus.pending
              ? 'Pending'
              : expense.status == ExpenseStatus.paid
              ? 'Paid'
              : 'Split',
          style: TextStyle(
            color: expense.status == ExpenseStatus.pending
                ? Colors.orange
                : expense.status == ExpenseStatus.paid
                ? Colors.green
                : Colors.blue,
          ),
        ),
      ),
    );
  }
}
