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

class EventService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');


  Future<String> _getCurrentUserEmail() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in or missing email');
    }
    return user.email!;
  }

  Future<List<Event>> fetchAllEventsForCurrentUser() async {
    final email = await _getCurrentUserEmail();

    final snapshot = await _firestore
        .collection('events')
        .where('acceptedParticipantEmails', arrayContains: email)
        .get();

    final events = <Event>[];
    for (final doc in snapshot.docs) {
      final transactions = await fetchTransactionsForEvent(doc.id);
      final event = Event.fromFirestore(doc, transactions: transactions);
      events.add(event);
    }

    return events;
  }


  Future<List<Event>> fetchEventsForUserAndStatus(EventStatus status) async {
    final email = await _getCurrentUserEmail();

    final snapshot = await _firestore
        .collection('events')
        .where('acceptedParticipantEmails', arrayContains: email)
        .where('status', isEqualTo: status.name)
        .get();

    final events = <Event>[];
    for (final doc in snapshot.docs) {
      final transactions = await fetchTransactionsForEvent(doc.id);
      final event = Event.fromFirestore(doc, transactions: transactions);
      events.add(event);
    }

    return events;
  }


  Future<void> addEvent(Event event) async {
    final json = event.toJson();
    await _firestore.collection('events').add(json);
  }

  Future<Event> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (!doc.exists) throw Exception('Event not found');

    final transactions = await fetchTransactionsForEvent(eventId);
    return Event.fromFirestore(doc, transactions: transactions);
  }

  Future<void> updateEvent(String eventId, Event event) async {
    await _firestore.collection('events').doc(eventId).update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<List<Invite>> getInvitesForUser(User user, InviteStatus status) async {
    final email = user.email?.toLowerCase();

    final statusFilter = switch (status) {
      InviteStatus.pending => 'invitedParticipantEmails',
      InviteStatus.accepted => 'acceptedParticipantEmails',
      InviteStatus.declined => 'declinedParticipantEmails',
    };

    final snapshot = await _firestore
        .collection('events')
        .where(statusFilter, arrayContains: email)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc).toInvite()).toList();
  }

  Future<void> addParticipantsToEvent(String eventId, List<String> participantEmails) async {
    final eventRef = _firestore.collection('events').doc(eventId);

    final snapshot = await eventRef.get();
    if (!snapshot.exists) {
      throw Exception("Event not found");
    }

    final List<dynamic> existingParticipants = snapshot.data()?['participants'] ?? [];

    final existingEmails = existingParticipants
        .map((p) => p['email'].toString().toLowerCase())
        .toSet();

    final newParticipantsEmails = participantEmails
        .where((email) => !existingEmails.contains(email));

    final newParticipants = newParticipantsEmails
        .map((email) => Participant(email: email).toJson())
        .toList();

    if (newParticipants.isEmpty) return;

    await eventRef.update({
      'participants': FieldValue.arrayUnion(newParticipants),
      'invitedParticipantEmails': FieldValue.arrayUnion(newParticipantsEmails.toList()),
    });
  }

  Future<void> updateParticipantStatus({
    required String eventId,
    required String email,
    required String status,
  }) async {
    final callable = functions.httpsCallable('updateParticipantStatus');
    await callable.call({
      'eventId': eventId,
      'email': email,
      'newStatus': status,
    });
  }

  double getUserBalance(Event event, String userUID) {
    var balance = 0.0;

    final totalExpenses = event.expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

    final userBalanceFromExpenses = event.expenses
        .where((expense) => expense.createdBy.firebaseUID == userUID)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);

    final userBalancePaidTransactions = event.transactions
        .where((transaction) => transaction.fromUserId == userUID && transaction.status == TransactionStatus.accepted)
        .fold<double>(0.0, (sum, transaction) => sum + transaction.amount);

    final userBalanceReceivedTransactions = event.transactions
        .where((transaction) => transaction.toUserId == userUID && transaction.status == TransactionStatus.accepted)
        .fold<double>(0.0, (sum, transaction) => sum + transaction.amount);

    final acceptedParticipantsCount = event.participants
        .where((p) => p.status == ParticipantStatus.accepted).length;

    final participantShare = totalExpenses / acceptedParticipantsCount;

    return balance
        + userBalanceFromExpenses
        + userBalancePaidTransactions
        - userBalanceReceivedTransactions
        - participantShare;
  }

  double getTotalSumPaid(Event event) {
    final totalTransactions = event.transactions
        .where((t) => t.status == TransactionStatus.accepted)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = event.expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

    final acceptedParticipantsCount = event.participants
        .where((p) => p.status == ParticipantStatus.accepted).length;

    final participantShare = totalExpenses / acceptedParticipantsCount;

    return totalTransactions + totalExpenses - participantShare;
  }

  Future<List<TransactionModel>> fetchTransactionsForEvent(String eventId) async {
    final querySnapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('transactions')
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.id, doc.data()))
        .toList();
  }


}
