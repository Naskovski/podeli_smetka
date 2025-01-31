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
    final userHasPaid = expense.paidBy
        .map((e) => e.user.firebaseUID)
        .contains(loggedInUser?.uid);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Статус:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  expense.status == ExpenseStatus.pending
                      ? 'Неисплатено'
                      : expense.status == ExpenseStatus.paid
                      ? 'Исплатено'
                      : 'Поделено',
                  style: TextStyle(
                    color: expense.status == ExpenseStatus.pending
                        ? Colors.orange
                        : expense.status == ExpenseStatus.paid
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Платено од:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...expense.paidBy.map((userPaid) => UserListItem(
              user: userPaid.user,
              size: 12,
              additionalText: '${userPaid.amount.toStringAsFixed(2)} MKD',
            )),
            const SizedBox(height: 16),
            Text(
              'Креирано од: ${expense.createdBy.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (userHasPaid)
              Text(
                'Вие плативте: ${expense.amount.toStringAsFixed(2)} MKD',
                style: const TextStyle(color: Colors.green),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showPaymentConfirmationDialog(context);
                  },
                  child: const Text('Потврди плаќање'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Потврди плаќање'),
          content: const Text(
              'Дали сте сигурни дека сте платиле на другиот корисник во готово?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Откажи'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Плаќањето е успешно потврдено!'),
                  ),
                );
              },
              child: const Text('Потврди'),
            ),
          ],
        );
      },
    );
  }
}