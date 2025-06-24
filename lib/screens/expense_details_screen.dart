import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podeli_smetka/widgets/user_list_item.dart';
import '../models/expense.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final Expense expense;
  final loggedInUser = FirebaseAuth.instance.currentUser;

  ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(
          expense.name,
          style: Theme.of(context).textTheme.headlineSmall,
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Износ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${expense.amount.toStringAsFixed(2)} MKD',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Креирано од: ${expense.createdBy.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}