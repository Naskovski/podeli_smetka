import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podeli_smetka/services/auth_service.dart';
import 'package:podeli_smetka/services/event_service.dart';

import '../models/invite.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  List<Invite> _invites = [];

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  void _fetchInvites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final invites = await EventService().getInvitesForUser(user);
      setState(() {
        _invites = invites;
      });
    }
  }

  void _acceptInvite(int index) {
    setState(() {
      _invites[index].status = InviteStatus.accepted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Прифативте покана за ${_invites[index].event.name}'),
      ),
    );
  }

  void _declineInvite(int index) {
    setState(() {
      _invites[index].status = InviteStatus.declined;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ја одбивте поканата за ${_invites[index].event.name}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профил'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user?.photoURL ?? ''),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.displayName ?? 'Anonymous',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.email ?? 'Нема е-пошта'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      _authService.signOutFromGoogle();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Одјави се'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_invites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Покани',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invites.length,
                      itemBuilder: (context, index) {
                        final invite = _invites[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: SizedBox(
                            height: 150,
                            child: ListTile(
                              title: Text(invite.event.name),
                              subtitle: Text(
                                'Организатор: ${invite.event.organizer.name}\n'
                                    'Локација: ${invite.event.location}\n'
                                    'Датум: ${invite.event.date.toString().split(' ')[0]}',
                              ),
                              trailing: SizedBox(
                                height: 100,
                                child: invite.status == InviteStatus.accepted
                                    ? const Text(
                                  'Прифатено',
                                  style: TextStyle(color: Colors.green),
                                )
                                    : invite.status == InviteStatus.declined
                                    ? const Text(
                                  'Одбиено',
                                  style: TextStyle(color: Colors.redAccent),
                                )
                                    : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _acceptInvite(index),
                                      child: const Text('Прифати'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _declineInvite(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: const Text('Одбиј', style: TextStyle( color: Colors.white),),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}