import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/services/event_service.dart';
import 'package:podeli_smetka/widgets/title_bar.dart';
import '../widgets/event_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    return Scaffold(
      appBar: const TitleBar(title: "Настани"),
      body: ListView.builder(
        itemCount: EventService.getAllEvents().length,
        itemBuilder: (context, index) {
          final event = EventService.getAllEvents()[index];
          return EventListItem(event: event);
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
