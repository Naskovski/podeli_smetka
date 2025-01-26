import 'package:flutter/material.dart';
import 'package:podeli_smetka/services/event_service.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Events'),
      ),
      body: ListView.builder(
        itemCount: EventService.getAllEvents().length,
        itemBuilder: (context, index) {
          final event = EventService.getAllEvents()[index];
          return EventCard(event: event);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Event Screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
