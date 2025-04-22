import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  List<Restaurant> restaurants = [];
  bool isLoading = true;

  // ——— FAVORITES ———
  static const _prefsKey = 'favorite_names';
  Set<String> _favorites = {};

  HomeViewModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_prefsKey) ?? [];
    _favorites = favs.toSet();
    notifyListeners();
  }

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

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
  // ——— /FAVORITES ———

  Future<void> loadRestaurants() async {
    isLoading = true;
    notifyListeners();

    try {
      print("Cargando restaurantes...");
      restaurants = await _restaurantRepository.fetchRestaurants();
      print("Restaurantes cargados: ${restaurants.length}");
    } catch (e) {
      print("Error al cargar restaurantes: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
