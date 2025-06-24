import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/models/event.dart';
import 'package:podeli_smetka/models/invite.dart';
import 'package:podeli_smetka/models/participant.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/expense.dart';
import '../models/transaction.dart';
import '../models/user_model.dart';

class TransactionService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');



  double getUserBalance(Event event, String userUID) {
    double totalOwedByUser = 0.0;
    double totalPaidByUser = 0.0;

    List<Participant> acceptedParticipants = event.participants
        .where((p) => p.status == ParticipantStatus.accepted)
        .toList();

    List<AppUser> acceptedUsers = acceptedParticipants.map((p) => p.user).whereType<AppUser>().toList();

    for (Expense expense in event.expenses) {
      int participantCount = acceptedParticipants.length;
      if (participantCount == 0) continue;

      double sharePerPerson = expense.amount / participantCount;

      if (acceptedParticipants.any((p) => p.user?.firebaseUID == userUID)) {
        totalOwedByUser += sharePerPerson;
      }

      if (expense.createdBy.firebaseUID == userUID) {
        totalPaidByUser += expense.amount;
      }
    }

    return totalPaidByUser - totalOwedByUser;
  }

  Future<List<TransactionModel>> getTransactionsForEvent(String eventId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('transactions')
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<void> addTransaction(String eventId, TransactionModel transaction) async {
    final docRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('transactions')
        .doc();
    await docRef.set(transaction.toJson());
  }

  Future<void> deleteTransaction(String eventId, String transactionId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  Future<void> updateTransactionStatus(String eventId, String transactionId, TransactionStatus status) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('transactions')
        .doc(transactionId)
        .update({'status': status.toString().split('.').last});
  }

}
