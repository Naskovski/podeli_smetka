import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event.dart';
import '../models/expense.dart';
import '../widgets/add_participants_dialog.dart';
import '../widgets/expense_card.dart';
import '../widgets/user_list_item.dart';
import 'new_expense_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final totalExpenses =
    event.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final paidExpenses = event.expenses
        .where((expense) => expense.status == ExpenseStatus.paid)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    // Mock calculation
    final userBalance = Random().nextInt(2001) - 1000;

    final currentUser = FirebaseAuth.instance.currentUser;
    final isOrganizer = currentUser?.uid == event.organizer.firebaseUID;

    return Scaffold(
      appBar: AppBar(title: Text(
          event.name,
          style: Theme.of(context).textTheme.headlineSmall,
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (event.location != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.pin_drop),
                  Text(
                    ' ${event.location}',
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
              itemCount: event.expenses.length,
              itemBuilder: (context, index) {
                final expense = event.expenses[index];
                return ExpenseCard(
                  expense: expense,
                );
              },
            ),
            const SizedBox(height: 16),

            if (isOrganizer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewExpenseScreen(eventId: event.id),
                      ),
                    );
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
            ...event.participants.map((p) => UserListItem(
              user: p,
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
                            // TODO: impl invite logic -> service.invite(emails, event)
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

            if (event.locationCoordinates != null)
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
                            event.locationCoordinates!['latitude']!,
                            event.locationCoordinates!['longitude']!,
                          ),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('eventLocation'),
                            position: LatLng(
                              event.locationCoordinates!['latitude']!,
                              event.locationCoordinates!['longitude']!,
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