import 'package:flutter/material.dart';
import 'package:podeli_smetka/services/event_service.dart';
import 'package:podeli_smetka/widgets/title_bar.dart';

import '../models/event.dart';
import '../widgets/event_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  EventStatus _selectedStatus = EventStatus.active;

  @override
  Widget build(BuildContext context) {
    final events = _selectedStatus == EventStatus.active
        ? _eventService.getActiveEvents()
        : _eventService.getCompletedEvents();

    return Scaffold(
      appBar: const TitleBar(title: "Настани"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<EventStatus>(
                segments: const [
                  ButtonSegment(
                    value: EventStatus.active,
                    label: Text('Активни'),
                  ),
                  ButtonSegment(
                    value: EventStatus.completed,
                    label: Text('Завршени'),
                  ),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (Set<EventStatus> newSelection) {
                  setState(() {
                    _selectedStatus = newSelection.first;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventListItem(event: event);
              },
            ),
          ),
        ],
      ),
    );
  }
}