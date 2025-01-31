import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/place.dart';

class MapsService {
  final String _mapsApiKey;

  MapsService() : _mapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<Place>> searchPlace(String query) async {
    if (query.isEmpty) return [];

    final places = GoogleMapsPlaces(apiKey: _mapsApiKey);
    final response = await places.searchByText(query);

    if (response.status == "OK") {
      return response.results.map((result) {
        return Place(
          name: result.name,
          placeId: result.placeId,
          location: LatLng(
            result.geometry!.location.lat,
            result.geometry!.location.lng,
          ),
          address: result.vicinity,
          rating: result.rating?.toDouble(),
        );
      }).toList();
    } else {
      throw Exception("Failed to fetch places: ${response.status}");
    }
  }
}