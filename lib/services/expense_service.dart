import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpenseToEvent(String eventId, Expense expense) async {
    final eventDocRef = _firestore.collection('events').doc(eventId);

    await eventDocRef.update({
      'expenses': FieldValue.arrayUnion([expense.toJson()]),
    });
  }
}
