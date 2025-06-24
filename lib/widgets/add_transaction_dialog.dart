import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../models/participant.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class AddTransactionDialog extends StatefulWidget {
  final Event event;
  final void Function()? onActionCompleted;

  const AddTransactionDialog({super.key, required this.event, this.onActionCompleted});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  String? _selectedUserId;
  double? _amount;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final acceptedParticipants = widget.event.participants
        .where((p) =>
            p.status == ParticipantStatus.accepted &&
            p.user != null &&
            p.user!.firebaseUID != currentUser?.uid)
        .toList();

    return AlertDialog(
      title: const Text('Додај трансакција'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: acceptedParticipants
                          .any((p) => p.user!.firebaseUID == _selectedUserId)
                      ? _selectedUserId
                      : null,
                  items: acceptedParticipants.map((p) {
                    final uid = p.user!.firebaseUID!;
                    return DropdownMenuItem<String>(
                      value: uid,
                      child: Text(p.user!.name ?? p.email),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedUserId = val),
                  validator: (val) => val == null ? 'Изберете учесник' : null,
                  decoration: const InputDecoration(labelText: 'До'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Износ'),
                  validator: (val) {
                    final d = double.tryParse(val ?? '');
                    if (d == null || d <= 0) return 'Внесете валиден износ';
                    return null;
                  },
                  onSaved: (val) => _amount = double.tryParse(val ?? ''),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Откажи'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              setState(() => _loading = true);

              final fromUserId = currentUser?.uid;
              final toUserId = _selectedUserId;
              final amount = _amount;

              if (fromUserId == null || toUserId == null || amount == null)
                return;

              final transaction = TransactionModel(
                fromUserId: fromUserId,
                toUserId: toUserId,
                amount: amount,
                status: TransactionStatus.pending,
              );

              await TransactionService()
                  .addTransaction(widget.event.id, transaction);

              widget.event.transactions.add(transaction);

              setState(() => _loading = false);
              if (widget.onActionCompleted != null) widget.onActionCompleted!();
              Navigator.of(context).pop();
            },
            child: const Text('Додај'),
          ),
        ]
      ],
    );
  }
}
