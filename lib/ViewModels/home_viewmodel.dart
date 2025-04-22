import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ConnectivityService connectivityService =  ConnectivityService();
  static const _prefsKey = 'favorite_names';
  Set<String> _favorites = {};
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  bool isOffline = false;

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);


  HomeViewModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_prefsKey) ?? [];
    _favorites = favs.toSet();
    notifyListeners();
  }



  Future<void> toggleFavorite(Restaurant r) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(r.name)) {
      _favorites.remove(r.name);
    } else {
      _favorites.add(r.name);
    }
    await prefs.setStringList(_prefsKey, _favorites.toList());
    notifyListeners();
  }

  Future<void> loadRestaurants() async {
    isLoading = true;
    notifyListeners();
    final isConnected = await connectivityService.isConnected();
    if (isConnected){
      isOffline = true;
      try {
        restaurants = await _restaurantRepository.fetchRestaurants();
      } catch (e) {
        print("Error al cargar restaurantes: $e");
      }

    }
    else{
      isOffline = false;
      restaurants = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
