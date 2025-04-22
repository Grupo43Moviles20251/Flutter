import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesViewModel extends ChangeNotifier {
  static const _prefsKey = 'favorite_names';

  final RestaurantRepository _repo = RestaurantRepository();

  /// Lista de restaurantes marcados como favoritos
  List<Restaurant> favorites = [];

  /// Control de estado de carga
  bool isLoading = true;

  /// Conjunto de nombres de restaurantes favoritos (persistido)
  Set<String> _favNames = {};

  FavoritesViewModel() {
    _init();
  }

  /// Inicializa: carga los nombres y luego la lista filtrada
  Future<void> _init() async {
    await _loadFavNames();
    await _fetchFavorites();
  }

  /// Carga el set de SharedPreferences
  Future<void> _loadFavNames() async {
    final prefs = await SharedPreferences.getInstance();
    _favNames = (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  /// Comprueba si un restaurante está en favoritos
  bool isFavorite(Restaurant r) => _favNames.contains(r.name);

  /// Alterna el estado de favorito y persiste el cambio
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

  /// Hace fetch de todos los restaurantes y luego filtra sólo los favoritos
  Future<void> _fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _repo.fetchRestaurants();
      favorites = all.where((r) => _favNames.contains(r.name)).toList();
    } catch (e) {
      favorites = [];
      print("Error cargando favoritos: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
