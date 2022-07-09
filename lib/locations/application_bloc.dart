import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yomate/locations/place_search.dart';
import 'package:yomate/services/geolocator_service.dart';

import '../services/place_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocationService = GeolocatorService();
  final placesService = PlacesService();

  late Position currentLocation;
  List<PlaceSearch> searchResults = [];

  ApplicationBloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await geoLocationService.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }
}
