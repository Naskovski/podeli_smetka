import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podeli_smetka/models/event.dart';

import '../models/expense.dart';
import '../models/user_model.dart';
import '../services/expense_service.dart';

class NewExpenseScreen extends StatefulWidget {
  final Event event;

  const NewExpenseScreen({super.key, required this.event});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  double amount = 0.0;

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мора да бидете најавени за да додадете трошок')),
        );
        return;
      }

      final newExpense = Expense(
        id: UniqueKey().toString(),
        name: name,
        description: description,
        amount: amount,
        createdBy: AppUser(
          firebaseUID: user.uid,
          name: user.displayName ?? 'Anonymous',
          email: user.email ?? '',
          photoURL: user.photoURL ?? '',
        ),
        createdAt: DateTime.now(),
      );

      try {
        setState(() {
          widget.event.expenses.add(newExpense);
        });

        await ExpenseService().addExpenseToEvent(widget.event.id, newExpense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успешно додаден трошок!')),
        );
        Navigator.pop(context, widget.event);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Додај нов трошок'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Има на трошокот'),
                onSaved: (value) {
                  name = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ве молам внесете име';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Опис'),
                onSaved: (value) {
                  description = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Износ'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  amount = double.tryParse(value ?? '0') ?? 0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ве молам внесете износ';
                  }
                  final parsedValue = double.tryParse(value);
                  if (parsedValue == null || parsedValue <= 0) {
                    return 'Ве молам внесете валидна вредност за износ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text('Зачувај трошок'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
