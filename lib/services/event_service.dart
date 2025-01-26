import 'package:podeli_smetka/models/event.dart';

import '../models/expense.dart';

class EventService{
  static List<Event> mockEvents = [
    Event(
      id: 'event1',
      name: 'Weekend Getaway',
      description: 'Trip to the mountains',
      status: EventStatus.active,
      date: DateTime.now().add(Duration(days: 2)),
      location: 'ChIJd_Y0eVIvkIARuQyDN0F1LBA', // Mock Google Places ID
      participants: ['user1', 'user2', 'user3'],
      expenses: [
        Expense(
          id: 'expense1',
          name: 'Gas',
          description: 'Fuel for the trip',
          status: ExpenseStatus.pending,
          paidBy: ['user1'],
          amount: 50.0,
          createdBy: 'user1',
          createdAt: DateTime.now(),
        ),
        Expense(
          id: 'expense2',
          name: 'Snacks',
          description: 'Food and drinks',
          status: ExpenseStatus.split,
          paidBy: ['user2', 'user3'],
          amount: 30.0,
          createdBy: 'user2',
          createdAt: DateTime.now(),
        ),
      ],
      organizer: 'user1',
    ),
  ];

  static List<Event> getAllEvents() {
    return mockEvents;
  }
}