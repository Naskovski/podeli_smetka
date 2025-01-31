import 'package:flutter/material.dart';

class AddParticipantsDialog extends StatefulWidget {
  final Function(List<String>) onInvite;

  const AddParticipantsDialog({super.key, required this.onInvite});

  @override
  _AddParticipantsDialogState createState() => _AddParticipantsDialogState();
}

class _AddParticipantsDialogState extends State<AddParticipantsDialog> {
  TextEditingController _emailController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();

  List<String> emails = [];

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_isDuplicate(email)) {
      setState(() {
        emails.add(email);
      });
      _emailController.clear();

      FocusScope.of(context).requestFocus(_emailFocusNode);
    }
  }

  bool _isDuplicate(String email) {
    return emails.contains(email);
  }

  void _inviteParticipants() {
    widget.onInvite(emails);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Додај учесници',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter participant email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _addEmail(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: emails
                  .map(
                    (email) => Chip(
                  label: Text(email),
                  onDeleted: () {
                    setState(() {
                      emails.remove(email);
                    });
                  },
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _inviteParticipants,
                child: const Text('Додади'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
