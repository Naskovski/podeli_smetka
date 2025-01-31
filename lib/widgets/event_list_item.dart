import 'package:flutter/material.dart';
import '../models/event.dart';
import '../screens/event_details_screen.dart';

class EventListItem extends StatelessWidget {
  final Event event;

  const EventListItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(event.name),
        subtitle: Text(event.description),
        trailing: Text(
          event.status == EventStatus.active ? 'Активен' : 'Завршен',
          style: TextStyle(
            color: event.status == EventStatus.active ? Colors.green : Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
      ),
    );
  }
}
