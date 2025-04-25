import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this import

import '../Models/restaurant_model.dart';
import '../Repositories/map_repository.dart';

class MapViewModel with ChangeNotifier {
  final MapRepository _repository = mapRepository();
  LatLng? _userLocation;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  LatLng? get userLocation => _userLocation;
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Restaurant? _selectedRestaurant;

  Restaurant? get selectedRestaurant => _selectedRestaurant;

  void reset() {
    _userLocation = null;
    _restaurants = [];
    _isLoading = true;
    _error = null;
    _selectedRestaurant = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    reset();
    await _getUserLocation();
    await _fetchRestaurants();
  }

  Future<void> _getUserLocation() async {
    try {
      // Check and request location permissions
      final status = await Permission.location.request();
      if (status.isGranted) {
        // Permission granted, get the user's location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _userLocation = LatLng(position.latitude, position.longitude);
      } else if (status.isDenied) {
        // Permission denied
        _error = 'Location permission denied. Please enable location access in settings.';
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, open app settings
        _error = 'Location permission permanently denied. Please enable it in app settings.';
        await openAppSettings(); // Open app settings to allow manual permission enabling
      }
    } catch (e) {
      _error = 'Error obtaining location: $e';
    }
    notifyListeners();
  }

  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  void clearSelection() {
    _selectedRestaurant = null;
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  Future<void> _fetchRestaurants() async {
    try {
      _restaurants = await _repository.fetchRestaurants();
      _isLoading = false;
    } catch (e) {
      _error = 'Error loading restaurants: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Set<Marker> getMarkers() {
    Set<Marker> markers = {};

    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var restaurant in _restaurants) {
      markers.add(
        Marker(
          markerId: MarkerId(restaurant.name),
          position: LatLng(restaurant.latitude, restaurant.longitude),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: restaurant.address,
          ),
          onTap: () {
            selectRestaurant(restaurant); // Selecciona el restaurante al tocar el marcador
          },
        ),
      );
    }
    return markers;
  }
}