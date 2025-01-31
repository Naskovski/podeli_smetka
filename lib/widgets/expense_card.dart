import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../screens/expense_details_screen.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailsScreen(expense: expense),
            ),
          );
        },
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description),
            Text(
              'Износ: ${expense.amount.toStringAsFixed(2)} ден.',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        trailing: Icon(
          expense.status == ExpenseStatus.pending
              ? Icons.pending
              : expense.status == ExpenseStatus.paid
              ? Icons.check_circle
              : Icons.group,
          color: expense.status == ExpenseStatus.pending
              ? Colors.orange
              : expense.status == ExpenseStatus.paid
              ? Colors.green
              : Colors.blue,
        ),
      ),
    );
  }
}
