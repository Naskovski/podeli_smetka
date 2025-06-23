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

  bool _isLoadingInvites = true;

  Set<int> _processingIndexes = {};
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  void _fetchInvites() async {
    setState(() {
      _isLoadingInvites = true;
    });

    if (user != null) {
      final invites = await EventService().getInvitesForUser(user!, InviteStatus.pending);
      setState(() {
        _invites = invites;
        _isLoadingInvites = false;
      });
    }
  }

  void _acceptInvite(int index) async {
    setState(() {
      _processingIndexes.add(index);
    });

    try {
      await EventService().updateParticipantStatus(
        eventId: _invites[index].event.id,
        email: user?.email ?? '',
        status: 'accepted',
      );

      setState(() {
        _invites[index].status = InviteStatus.accepted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Прифативте покана за ${_invites[index].event.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при прифаќање: $e')),
      );
      throw e;
    } finally {
      setState(() {
        _processingIndexes.remove(index);
      });
    }
  }

  void _declineInvite(int index) async {
    setState(() {
      _processingIndexes.add(index);
    });

    try {
      await EventService().updateParticipantStatus(
        eventId: _invites[index].event.id,
        email: user?.email ?? '',
        status: 'declined',
      );

      setState(() {
        _invites[index].status = InviteStatus.declined;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ја одбивте поканата за ${_invites[index].event.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при одбивање: $e')),
      );
    } finally {
      setState(() {
        _processingIndexes.remove(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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

            if (_isLoadingInvites)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_invites.isNotEmpty)

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
                        final isProcessing = _processingIndexes.contains(index);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(invite.event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 6),
                                      Text('Организатор: ${invite.event.organizer.name}'),
                                      Text('Локација: ${invite.event.location}'),
                                      Text('Датум: ${invite.event.date.toString().split(' ')[0]}'),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                SizedBox(
                                  width: 110,
                                  child: isProcessing
                                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                      : invite.status == InviteStatus.accepted
                                      ? const Text('Прифатено', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                      : invite.status == InviteStatus.declined
                                      ? const Text('Одбиено', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                                      : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _acceptInvite(index),
                                          child: const Text('Прифати'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _declineInvite(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Одбиј', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
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
