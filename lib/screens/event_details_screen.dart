import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/event.dart';
import '../models/participant.dart';
import '../services/event_service.dart';
import '../services/transaction_service.dart';
import '../widgets/add_participants_dialog.dart';
import '../widgets/expense_card.dart';
import '../widgets/user_list_item.dart';
import 'new_expense_screen.dart';
import 'transaction_details_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    final transactions = await TransactionService().getTransactionsForEvent(_event.id);
    setState(() {
      _event.transactions = transactions;
    });
  }

  Future<void> _addParticipants(List<String> emails, ) async {
    try {
      await EventService().addParticipantsToEvent(widget.event.id, emails);
      setState(() {
        final existing = widget.event.participants.map((p) => p.email.toLowerCase()).toSet();
        final newOnes = emails
            .where((email) => !existing.contains(email.toLowerCase()))
            .map((email) => Participant(email: email.trim()))
            .toList();
        widget.event.participants.addAll(newOnes);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Учесниците се додадени.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неуспешно додавање: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses =
    _event.expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final userBalance = EventService().getUserBalance(_event, FirebaseAuth.instance.currentUser?.uid ?? '');
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOrganizer = currentUser?.uid == _event.organizer.firebaseUID;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _event.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (_event.location != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.pin_drop),
                  Text(
                    ' ${_event.location}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            const SizedBox(height: 24),

            Text(
              'Трошоци',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _event.expenses.length,
              itemBuilder: (context, index) {
                final expense = _event.expenses[index];
                return ExpenseCard(expense: expense);
              },
            ),
            const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updatedEvent = await Navigator.push<Event>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewExpenseScreen(event: _event),
                      ),
                    );

                    if (updatedEvent != null) {
                      setState(() {
                        _event = updatedEvent;
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Додај нов трошок'),
                ),
              ),
            const SizedBox(height: 16),

            Text(
              'Вкупно: ${totalExpenses.toStringAsFixed(2)} ден.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              userBalance > 0
                  ? 'Треба да добиете: ${userBalance.toStringAsFixed(2)} ден.'
                  : userBalance == 0
                      ? "Не должите никому, и никој не ви должи"
                      : 'Должите: ${(-userBalance).toStringAsFixed(2)} ден.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updatedEvent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionDetailsScreen(event: _event),
                    ),
                  );
                  if (updatedEvent != null) {
                    setState(() {
                      _event = updatedEvent;
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Плаќања'),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Учесници:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._event.participants.map((p) => UserListItem(
              user: p.user,
              email: p.email,
              size: 12,
              additionalText: p.status == ParticipantStatus.invited
                      ? 'Чека на потврда'
                      : p.status == ParticipantStatus.accepted
                          ? 'Потврден учесник'
                          : 'Одбива учество',
                )),
            const SizedBox(height: 16),

            if (isOrganizer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddParticipantsDialog(
                          onInvite: _addParticipants,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Додај учесник'),
                ),
              ),
            const SizedBox(height: 16),

            if (_event.locationCoordinates != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мапа',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 400,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _event.locationCoordinates!['lat']!,
                            _event.locationCoordinates!['lng']!,
                          ),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('eventLocation'),
                            position: LatLng(
                              _event.locationCoordinates!['lat']!,
                              _event.locationCoordinates!['lng']!,
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ),

            if (isOrganizer) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await EventService().updateEventStatus(_event, EventStatus.completed);
                      setState(() {
                        _event.status = EventStatus.completed;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Настанот е успешно завршен.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Грешка при завршување на настанот: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_outlined),
                  label: const Text('Заврши Настан'),
                ),
              ),
            ]

          ],
        ),
      ),
    );
  }
}
