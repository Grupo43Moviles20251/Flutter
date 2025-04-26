import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../Services/connection_helper.dart';

class SearchViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ConnectivityService connectivityService = ConnectivityService();
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  bool isOffline = false;
  String? errorMessage;

  // ——— FAVORITES ———
  Set<String> _favorites = {};
  static Database? _database; // Misma instancia de base de datos

  // ——— STREAM ———
  final StreamController<List<Restaurant>> _searchStreamController =
  StreamController<List<Restaurant>>.broadcast();
  Stream<List<Restaurant>> get searchStream => _searchStreamController.stream;

  SearchViewModel() {
    _initDatabaseConnection().then((_) => _loadFavorites());
  }

  // Conectar a la base de datos existente
  Future<void> _initDatabaseConnection() async {
    _database ??= await openDatabase(
        join(await getDatabasesPath(), 'favorites_database.db'),
        version: 1,
        // No necesitamos onCreate porque la tabla ya existe
      );
  }

  Future<void> _loadFavorites() async {
    if (_database == null) await _initDatabaseConnection();

    try {
      final List<Map<String, dynamic>> maps = await _database!.query('favorites');
      _favorites = maps.map((map) => map['name'] as String).toSet();
      notifyListeners();
    } catch (e) {
      print("Error cargando favoritos: $e");
      _favorites = {};
    }
  }

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

  Future<void> toggleFavorite(Restaurant r) async {
    if (_database == null) await _initDatabaseConnection();

    try {
      if (_favorites.contains(r.name)) {
        _favorites.remove(r.name);
        await _database!.delete(
          'favorites',
          where: 'name = ?',
          whereArgs: [r.name],
        );
      } else {
        _favorites.add(r.name);
        await _database!.insert(
          'favorites',
          {'name': r.name},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error actualizando favorito: $e");
    }
  }

  // ——— /FAVORITES ———

  Future<void> searchRestaurants(BuildContext context, query, {int? type}) async {
    if (query.isEmpty && type == null) {
      return loadAllRestaurants(context);
    }

    isLoading = true;
    notifyListeners();

    try {
      restaurants = await _restaurantRepository.searchRestaurants(query, type: type);
      _searchStreamController.add(restaurants);
    } catch (e) {
      errorMessage = "Search failed";
      print("Error buscando restaurantes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllRestaurants(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
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
      restaurants = await _restaurantRepository.fetchRestaurants();
      _searchStreamController.add(restaurants);
    } catch (e) {
      errorMessage = "Failed to load restaurants";
      print("Error al cargar restaurantes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> close() async {
    // No cerramos la base de datos aquí para no afectar a otros ViewModels
    await _searchStreamController.close();
  }
}