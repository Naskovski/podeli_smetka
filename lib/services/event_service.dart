import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/models/event.dart';
import 'package:podeli_smetka/models/invite.dart';
import 'package:podeli_smetka/models/participant.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  Future<List<Event>> fetchEventsForUserAndStatus(EventStatus status) async {
    final email = await _getCurrentUserEmail();

    final snapshot = await _firestore
        .collection('events')
        .where('acceptedParticipantEmails', arrayContains: email)
        .where('status', isEqualTo: status.name)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  Future<void> addEvent(Event event) async {
    final json = event.toJson();
    await _firestore.collection('events').add(json);
  }

  Future<Event> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (!doc.exists) throw Exception('Event not found');
    return Event.fromFirestore(doc);
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
}
