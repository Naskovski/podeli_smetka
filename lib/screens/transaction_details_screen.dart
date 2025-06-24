import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/transaction.dart';
import '../models/participant.dart';
import '../widgets/transaction_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../services/transaction_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Event event;
  const TransactionDetailsScreen({super.key, required this.event});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late Event _event;
  late List<TransactionModel> _transactions;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _transactions = _event.transactions ?? [];
  }

  Future<void> _refreshTransactions() async {
    final transactions = await TransactionService().getTransactionsForEvent(_event.id);
    setState(() {
      _transactions = transactions;
    });
  }

  void _addTransaction() async {
    await showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        event: _event,
        onActionCompleted: _refreshTransactions,
      ),
    );
    await _refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Плаќања')),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text('Нема трансакции.'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        transaction: _transactions[index],
                        event: _event,
                        onActionCompleted: _refreshTransactions,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTransaction,
                icon: const Icon(Icons.add),
                label: const Text('Додај трансакција'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
