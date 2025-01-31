import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/models/event.dart';
import 'package:podeli_smetka/models/invite.dart';
import 'package:podeli_smetka/services/expense_service.dart';
import 'package:podeli_smetka/services/user_service.dart';

import '../models/expense.dart';
import '../models/user_model.dart';

class EventService {
  final List<AppUser> mockUsers;
  final List<Expense> mockExpenses;
  final List<Event> mockEvents;
  final List<Invite> mockInvites;

  EventService()
      : mockUsers = UserDataService().getAllUsers(),
        mockExpenses = ExpenseService().getAllExpenses(),
        mockEvents = [
          Event(
            id: 'event1',
            name: 'Роденденска забава',
            description: 'Прослава на роденден со пријателите',
            status: EventStatus.active,
            date: DateTime.now().add(const Duration(days: 5)),
            location: 'Кафуле Скопје',
            locationCoordinates: {'latitude': 41.9981, 'longitude': 21.4254},
            participants: [
              UserDataService().getAllUsers()[0],
              UserDataService().getAllUsers()[1],
              UserDataService().getAllUsers()[2],
            ],
            expenses: [
              ExpenseService().getAllExpenses()[0],
              ExpenseService().getAllExpenses()[4],
            ],
            organizer: UserDataService().getAllUsers()[0],
          ),
          Event(
            id: 'event2',
            name: 'Патување на Попова Шапка',
            description: 'Скијање и зимска авантура со друштвото',
            status: EventStatus.completed,
            date: DateTime.now().subtract(const Duration(days: 10)),
            location: 'Попова Шапка',
            locationCoordinates: {'latitude': 42.0102, 'longitude': 20.9093},
            participants: [
              UserDataService().getAllUsers()[1],
              UserDataService().getAllUsers()[2],
            ],
            expenses: [
              ExpenseService().getAllExpenses()[1],
              ExpenseService().getAllExpenses()[3],
            ],
            organizer: UserDataService().getAllUsers()[1],
          ),
          Event(
            id: 'event3',
            name: 'Концерт во Градски Парк',
            description: 'Настап на познати бендови',
            status: EventStatus.active,
            date: DateTime.now().add(const Duration(days: 3)),
            location: 'Градски Парк, Скопје',
            locationCoordinates: {'latitude': 41.9985, 'longitude': 21.4278},
            participants: [
              UserDataService().getAllUsers()[3],
              UserDataService().getAllUsers()[4],
            ],
            expenses: [ExpenseService().getAllExpenses()[2]],
            organizer: UserDataService().getAllUsers()[3],
          ),
          Event(
            id: 'event4',
            name: 'Летен одмор во Грција',
            description: 'Заедничко патување на море',
            status: EventStatus.active,
            date: DateTime.now().add(const Duration(days: 20)),
            location: 'Паралија, Грција',
            locationCoordinates: {'latitude': 40.2710, 'longitude': 22.5950},
            participants: [
              UserDataService().getAllUsers()[0],
              UserDataService().getAllUsers()[1],
              UserDataService().getAllUsers()[2],
              UserDataService().getAllUsers()[4],
            ],
            expenses: [],
            organizer: UserDataService().getAllUsers()[0],
          ),
          Event(
            id: 'event5',
            name: 'Филмска вечер',
            description: 'Гледање филмови со друштво',
            status: EventStatus.completed,
            date: DateTime.now().subtract(const Duration(days: 7)),
            location: 'Дом на култура',
            locationCoordinates: {'latitude': 41.6101, 'longitude': 21.7168},
            participants: [
              UserDataService().getAllUsers()[1],
              UserDataService().getAllUsers()[3],
            ],
            expenses: [ExpenseService().getAllExpenses()[3]],
            organizer: UserDataService().getAllUsers()[1],
          ),
        ],
        mockInvites = [
          Invite(
            id: 'invite1',
            event: Event(
              id: 'event1',
              name: 'Роденденска забава',
              description: 'Прослава на роденден со пријателите',
              status: EventStatus.active,
              date: DateTime.now().add(const Duration(days: 5)),
              location: 'Кафуле Скопје',
              locationCoordinates: {'latitude': 41.9981, 'longitude': 21.4254},
              participants: [
                UserDataService().getAllUsers()[0],
                UserDataService().getAllUsers()[1],
                UserDataService().getAllUsers()[2],
              ],
              expenses: [
                ExpenseService().getAllExpenses()[0],
                ExpenseService().getAllExpenses()[4],
              ],
              organizer: UserDataService().getAllUsers()[0],
            ),
            invitee: UserDataService().getAllUsers()[2],
            invited: UserDataService().getCurrentUser(),
            sentAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Invite(
            id: 'invite2',
            event: Event(
              id: 'event2',
              name: 'Патување на Попова Шапка',
              description: 'Скијање и зимска авантура со друштвото',
              status: EventStatus.completed,
              date: DateTime.now().subtract(const Duration(days: 10)),
              location: 'Попова Шапка',
              locationCoordinates: {'latitude': 42.0102, 'longitude': 20.9093},
              participants: [
                UserDataService().getAllUsers()[1],
                UserDataService().getAllUsers()[2],
              ],
              expenses: [
                ExpenseService().getAllExpenses()[1],
                ExpenseService().getAllExpenses()[3],
              ],
              organizer: UserDataService().getAllUsers()[1],
            ),
            invitee: UserDataService().getAllUsers()[0],
            invited: UserDataService().getCurrentUser(),
            sentAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

  List<Event> getAllEvents() {
    return mockEvents;
  }

  List<Event> getActiveEvents() {
    return mockEvents.where((event) => event.status == EventStatus.active).toList();
  }

  List<Event> getCompletedEvents() {
    return mockEvents.where((event) => event.status == EventStatus.completed).toList();
  }

  List<Invite> getInvitesForUser(User user) {
    return mockInvites.where((invite) => invite.invited.firebaseUID == user.uid && invite.status == InviteStatus.pending).toList();
  }
}