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

  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _eventsFuture = _eventService.fetchEventsForUserAndStatus(_selectedStatus);
  }

  void _onStatusChanged(EventStatus newStatus) {
    setState(() {
      _selectedStatus = newStatus;
      _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  _onStatusChanged(newSelection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Грешка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нема настани за прикажување.'));
                }

                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return EventListItem(event: events[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
