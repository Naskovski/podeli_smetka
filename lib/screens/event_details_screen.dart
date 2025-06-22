import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/event.dart';
import '../models/expense.dart';
import '../widgets/add_participants_dialog.dart';
import '../widgets/expense_card.dart';
import '../widgets/user_list_item.dart';
import 'new_expense_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses =
    _event.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final paidExpenses = _event.expenses
        .where((expense) => expense.status == ExpenseStatus.paid)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final userBalance = Random().nextInt(2001) - 1000;
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

            if (isOrganizer)
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
              'Вкупно: ${paidExpenses.toStringAsFixed(2)} / ${totalExpenses.toStringAsFixed(2)} ден.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              userBalance > 0
                  ? 'Треба да добиете: ${userBalance.toStringAsFixed(2)} ден.'
                  : 'Должите: ${(-userBalance).toStringAsFixed(2)} ден.',
              style: Theme.of(context).textTheme.titleMedium,
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
                          onInvite: (List<String> emails) {
                            // TODO: implement invite logic
                          },
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
          ],
        ),
      ),
    );
  }
}
