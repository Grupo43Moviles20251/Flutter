import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FavoritesViewModel extends ChangeNotifier {
  static const _prefsKey = 'favorite_names';

  final RestaurantRepository _repo = RestaurantRepository();
  List<Restaurant> favorites = [];
  bool isLoading = true;
  Set<String> _favNames = {};

  // Stream for favorites
  final StreamController<List<Restaurant>> _favoritesStreamController = StreamController<List<Restaurant>>.broadcast();
  Stream<List<Restaurant>> get favoritesStream => _favoritesStreamController.stream;

  FavoritesViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _loadFavNames();
    await _fetchFavorites();
  }

  Future<void> _loadFavNames() async {
    final prefs = await SharedPreferences.getInstance();
    _favNames = (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  bool isFavorite(Restaurant r) => _favNames.contains(r.name);

  Future<void> toggleFavorite(Restaurant r) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favNames.contains(r.name)) {
      _favNames.remove(r.name);
    } else {
      _favNames.add(r.name);
    }
    await prefs.setStringList(_prefsKey, _favNames.toList());
    await _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _repo.fetchRestaurants();
      favorites = all.where((r) => _favNames.contains(r.name)).toList();

      // Emit updated favorites to the stream
      _favoritesStreamController.add(favorites);
    } catch (e) {
      favorites = [];
      print("Error cargando favoritos: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
