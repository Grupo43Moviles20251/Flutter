import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/connection_helper.dart';

class SearchViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ConnectivityService connectivityService = ConnectivityService();
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  bool isOffline = false;
  String? errorMessage;

  // ——— FAVORITES ———
  static const _prefsKey = 'favorite_names';
  Set<String> _favorites = {};

  SearchViewModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList(_prefsKey) ?? []).toSet();
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

  Future<void> loadAllRestaurants() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final isConnected = await connectivityService.isConnected();
    isOffline = !isConnected;

    if (!isConnected) {
      isLoading = false;
      errorMessage = "No internet connection";
      notifyListeners();
      return;
    }

    try {
      restaurants = await _restaurantRepository.fetchRestaurants();
    } catch (e) {
      errorMessage = "Failed to load restaurants";
      print("Error al cargar restaurantes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRestaurants(BuildContext context, query, {int? type}) async {
    if (query.isEmpty && type == null) {
      return loadAllRestaurants();
    }

    isLoading = true;
    notifyListeners();

    final isConnected = await connectivityService.isConnected();
    isOffline = !isConnected;

    if (!isConnected) {
      isLoading = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection. Try again when you\'re back online.'),
              duration: Duration(seconds: 3),
            ));
        }
            notifyListeners();
        return;
      }

      try {
        restaurants = await _restaurantRepository.searchRestaurants(query, type: type);
      } catch (e) {
        errorMessage = "Search failed";
        print("Error buscando restaurantes: $e");
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
}
