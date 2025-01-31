import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String name;
  final String placeId;
  final LatLng location;
  final String? address;
  final double? rating;

  Place({
    required this.name,
    required this.placeId,
    required this.location,
    this.address,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'placeId': placeId,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'address': address,
      'rating': rating,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      placeId: json['placeId'],
      location: LatLng(
        json['location']['lat'],
        json['location']['lng'],
      ),
      address: json['address'],
      rating: json['rating'],
    );
  }
}