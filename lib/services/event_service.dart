import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/models/event.dart';
import 'package:podeli_smetka/models/invite.dart';
import 'package:podeli_smetka/models/participant.dart';

class EventService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Get the currently logged-in user's email
  Future<String> _getCurrentUserEmail() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in or missing email');
    }
    return user.email!;
  }

  /// Fetch all events where the user is a participant
  Future<List<Event>> fetchAllEventsForCurrentUser() async {
    final email = await _getCurrentUserEmail();

    final snapshot = await _firestore
        .collection('events')
        .where('participantEmails', arrayContains: email)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  /// Fetch events filtered by EventStatus (active or completed)
  Future<List<Event>> fetchEventsForUserAndStatus(EventStatus status) async {
    final email = await _getCurrentUserEmail();

    final snapshot = await _firestore
        .collection('events')
        .where('participantEmails', arrayContains: email)
        .where('status', isEqualTo: status.name)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  /// Add a new event to Firestore
  Future<void> addEvent(Event event) async {
    final json = event.toJson(); // includes participantEmails
    await _firestore.collection('events').add(json);
  }

  /// Fetch a specific event by ID
  Future<Event> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (!doc.exists) throw Exception('Event not found');
    return Event.fromFirestore(doc);
  }

  /// Optional: Update an existing event
  Future<void> updateEvent(String eventId, Event event) async {
    await _firestore.collection('events').doc(eventId).update(event.toJson());
  }

  /// Optional: Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  /// Placeholder: Fetch invites (use Firestore if implemented)
  Future<List<Invite>> getInvitesForUser(User user) async {
    // TODO: Replace with Firestore invite fetching logic if needed
    return []; // Implement as needed
  }

  Future<void> addParticipantsToEvent(String eventId, List<String> emails) async {
    final eventRef = _firestore.collection('events').doc(eventId);

    final snapshot = await eventRef.get();
    if (!snapshot.exists) {
      throw Exception("Event not found");
    }

    final List<dynamic> existingParticipants = snapshot.data()?['participants'] ?? [];

    final existingEmails = existingParticipants.map((p) => p['email'].toString().toLowerCase()).toSet();
    final newEmails = emails.where((e) => !existingEmails.contains(e.toLowerCase())).toList();

    final newParticipants = newEmails
        .map((email) => {'email': email.trim()})
        .toList();

    if (newParticipants.isEmpty) return;

    await eventRef.update({
      'participants': FieldValue.arrayUnion(newParticipants),
    });
  }
}
