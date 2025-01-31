import 'package:podeli_smetka/services/user_service.dart';

import '../models/expense.dart';
import '../models/user_paid.dart';

class ExpenseService {
  final List<Expense> _expenses;

  ExpenseService() : _expenses = _initializeMockExpenses();

  static List<Expense> _initializeMockExpenses() {
    final mockUsers = UserDataService().getAllUsers();

    return [
      Expense(
        id: 'expense1',
        name: 'Ручек во ресторан',
        description: 'Заеднички ручек со пријатели',
        status: ExpenseStatus.paid,
        paidBy: [
          UserPaid(user: mockUsers[0], amount: 100.0),
          UserPaid(user: mockUsers[1], amount: 100.0),
        ],
        amount: 200.0,
        createdBy: mockUsers[0],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Expense(
        id: 'expense2',
        name: 'Ноќевање во Охрид',
        description: 'Сместување за викенд патување',
        status: ExpenseStatus.split,
        paidBy: [
          UserPaid(user: mockUsers[2], amount: 150.0),
        ],
        amount: 150.0,
        createdBy: mockUsers[2],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Expense(
        id: 'expense3',
        name: 'Карти за концерт',
        description: 'Концерт на омилената група',
        status: ExpenseStatus.paid,
        paidBy: [
          UserPaid(user: mockUsers[4], amount: 50.0),
          UserPaid(user: mockUsers[3], amount: 50.0),
        ],
        amount: 100.0,
        createdBy: mockUsers[3],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Expense(
        id: 'expense4',
        name: 'Гориво за патување',
        description: 'Гориво за викенд патување',
        status: ExpenseStatus.split,
        paidBy: [
          UserPaid(user: mockUsers[1], amount: 80.0),
          UserPaid(user: mockUsers[2], amount: 80.0),
        ],
        amount: 160.0,
        createdBy: mockUsers[1],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Expense(
        id: 'expense5',
        name: 'Пијалоци за забава',
        description: 'Пијалоци за роденденската забава',
        status: ExpenseStatus.paid,
        paidBy: [
          UserPaid(user: mockUsers[0], amount: 120.0),
        ],
        amount: 120.0,
        createdBy: mockUsers[0],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Expense> getAllExpenses() {
    return _expenses;
  }
}