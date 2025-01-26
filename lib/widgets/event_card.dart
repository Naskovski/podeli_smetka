import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(event.name),
        subtitle: Text(event.description),
        trailing: Text(
          event.status == EventStatus.active ? 'Active' : 'Completed',
          style: TextStyle(
            color: event.status == EventStatus.active ? Colors.green : Colors.grey,
          ),
        ),
        onTap: () {
          // Navigate to Event Details Screen
        },
      ),
    );
  }
}
