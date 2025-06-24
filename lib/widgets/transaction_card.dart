import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/participant.dart';
import '../models/transaction.dart';
import '../models/event.dart';
import '../services/transaction_service.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Event event;
  final void Function()? onActionCompleted;

  const TransactionCard({super.key, required this.transaction, required this.event, this.onActionCompleted});


  String _getUserName(String userId) {
    final participant = event.participants.firstWhere(
          (p) => p.user?.firebaseUID == userId,
      orElse: () => Participant(
        email: '',
        status: ParticipantStatus.accepted,
        user: null,
      ),
    );

    if (participant.user?.firebaseUID == FirebaseAuth.instance.currentUser?.uid) {
      return 'Вие';
    }

    return participant?.user?.name ?? 'Непознат корисник';
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.swap_horiz),
        title: Text(
          '${_getUserName(transaction.fromUserId)} → ${_getUserName(transaction.toUserId)}',
        ),
        subtitle: Text('Износ: ${transaction.amount.toStringAsFixed(2)} ден.'),

        trailing: Builder(
          builder: (context) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              return Text(_statusText(transaction.status));
            }
            if (transaction.toUserId == currentUser.uid &&
                transaction.status == TransactionStatus.pending) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      await TransactionService().updateTransactionStatus(
                        event.id,
                        transaction.id,
                        TransactionStatus.accepted,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Трансакцијата е прифатена.')),
                      );
                      if (onActionCompleted != null) onActionCompleted!();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () async {
                      await TransactionService().updateTransactionStatus(
                        event.id,
                        transaction.id,
                        TransactionStatus.declined,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Трансакцијата е одбиена.')),
                      );
                      if (onActionCompleted != null) onActionCompleted!();
                    },
                  ),
                ],
              );
            } else if (transaction.fromUserId == currentUser.uid &&
                transaction.status == TransactionStatus.pending) {
              return IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () async {
                  await TransactionService().deleteTransaction(
                    event.id,
                    transaction.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Трансакцијата е избришана.')),
                  );
                  if (onActionCompleted != null) onActionCompleted!();
                },
              );
            } else {
              return Text(_statusText(transaction.status));
            }
          },
        ),
      ),
    );
  }

  String _statusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'На чекање';
      case TransactionStatus.accepted:
        return 'Прифатено';
      case TransactionStatus.declined:
        return 'Одбиено';
    }
  }
}
