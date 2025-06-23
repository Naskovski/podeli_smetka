import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podeli_smetka/models/participant.dart';

import '../models/event.dart';
import '../models/user_model.dart';
import '../services/maps_service.dart';
import '../widgets/add_participants_dialog.dart';
import '../widgets/google_map_widget.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  _NewEventScreenState createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final MapsService _mapsService = MapsService();
  Set<Marker> _markers = {};
  final String mapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  final user = FirebaseAuth.instance.currentUser;

  LatLng? _selectedLocation;
  List<String> participantsEmails = [];
  bool _isSearching = false;

  void _searchPlace() async {
    final place = _searchController.text.trim();
    if (place.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final places = await _mapsService.searchPlace(place);

      if (places.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Изберете локација'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return ListTile(
                      title: Text(place.name),
                      subtitle: Text(place.address ?? ''),
                      onTap: () {
                        setState(() {
                          _markers.clear();
                          _markers.add(Marker(
                            markerId: MarkerId(place.placeId),
                            position: place.location,
                            infoWindow: InfoWindow(
                              title: place.name,
                              snippet: place.address,
                            ),
                          ));

                          _selectedLocation = place.location;

                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                          );
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при пребарување на локација: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нов Настан')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Име на настанот'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Опис на настанот'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Учесници:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              participantsEmails.isEmpty
                  ? const Text(
                'Нема додадено учесници.',
                style: TextStyle(color: Colors.grey),
              )
                  : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: participantsEmails.map((email) => Chip(
                  label: Text(email),
                  onDeleted: () {
                    setState(() {
                      participantsEmails.remove(email);
                    });
                  },
                )).toList(),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddParticipantsDialog(
                          onInvite: (List<String> emails) {
                            setState(() {
                              participantsEmails.addAll(emails);
                            });
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Додај учесник'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Пребарај локација',
                  suffixIcon: IconButton(
                    icon: _isSearching
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.search),
                    onPressed: _searchPlace,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GoogleMapWidget(
                initialLocation:
                _selectedLocation ?? const LatLng(41.6086, 21.7453),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty || _selectedLocation == null) {
                      print('title: $title, description: $description, location: $_selectedLocation');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пополнете ги сите полиња и изберете локација.')),
                      );
                      return;
                    }

                    try {
                      var participants = participantsEmails.map((email) => Participant(email: email.trim())).toList();
                      participants.add(Participant(email: user!.email!, status: ParticipantStatus.accepted));

                      final event = Event(
                        id: '',
                        name: title,
                        description: description,
                        status: EventStatus.active,
                        date: DateTime.now(),
                        location: null,
                        locationCoordinates: {
                          'lat': _selectedLocation!.latitude,
                          'lng': _selectedLocation!.longitude,
                        },
                        participants: participants,
                        expenses: [],
                        organizer: AppUser(
                                firebaseUID: user?.uid ?? '',
                                name: user?.displayName ?? '',
                                email: user?.email ?? '',
                                photoURL: user?.photoURL ?? ''
                        ),
                      );

                      final docRef = await FirebaseFirestore.instance.collection('events').add(event.toJson());

                      // TODO: Optionally call a Cloud Function to send invitations

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Настанот е зачуван!')),
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Грешка при зачувување: $e')),
                      );
                    }
                  },

                  child: const Text('Зачувај настан'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}