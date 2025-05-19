import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
    try {
      reset();
      await _getUserLocation();
      await _fetchRestaurants();
    } catch (e) {
      _error = 'Initialization error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserLocation() async {
    try {
      await _getUserLocation();
      notifyListeners();
    } catch (e) {
      _error = 'Error updating location: $e';
      notifyListeners();
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        _userLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();
      } else if (status.isDenied) {
        _error = 'Location permission denied. Please enable location access in settings.';
      } else if (status.isPermanentlyDenied) {
        _error = 'Location permission permanently denied. Please enable it in app settings.';
        await openAppSettings();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error obtaining location: $e';
      notifyListeners();
    }
  }

  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRestaurant = null;
    notifyListeners();
  }

  Future<void> _fetchRestaurants() async {
    try {
      _restaurants = await _repository.fetchRestaurants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error loading restaurants: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Set<Marker> getMarkers() {
    Set<Marker> markers = {};

    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      for (var restaurant in _restaurants) {
        // Calcular la distancia entre el usuario y el restaurante
        double distanceInMeters = Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          restaurant.latitude,
          restaurant.longitude,
        );

        // Convertir a kilómetros
        double distanceInKm = distanceInMeters / 1000;

        // Determinar el color del marcador basado en la distancia
        BitmapDescriptor markerColor;
        if (distanceInKm <= 1.0) {
          // Dentro de 1 km - verde
          markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        } else {
          // Fuera de 1 km - rojo
          markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        }

        markers.add(
          Marker(
            markerId: MarkerId(restaurant.name),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: '${restaurant.address} (${distanceInKm.toStringAsFixed(2)} km)',
            ),
            icon: markerColor, // Usar el color determinado
            onTap: () => selectRestaurant(restaurant),
          ),
        );
      }
    }
    return markers;
  }
}