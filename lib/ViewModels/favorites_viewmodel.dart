import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class FavoritesViewModel extends ChangeNotifier {
  final RestaurantRepository _repo = RestaurantRepository();
  List<Restaurant> favorites = [];
  bool isLoading = true;

  // Stream for favorites
  final StreamController<List<Restaurant>> _favoritesStreamController =
  StreamController<List<Restaurant>>.broadcast();
  Stream<List<Restaurant>> get favoritesStream => _favoritesStreamController.stream;

  // Database instance
  static Database? _database;

  FavoritesViewModel() {
    _initDatabase().then((_) => fetchFavorites());
  }

  // Initialize database
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'favorites_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, name TEXT UNIQUE)',
        );
      },
      version: 1,
    );
  }

  // Check if a restaurant is favorite
  Future<bool> isFavorite(Restaurant r) async {
    if (_database == null) await _initDatabase();

    final List<Map<String, dynamic>> maps = await _database!.query(
      'favorites',
      where: 'name = ?',
      whereArgs: [r.name],
    );

    return maps.isNotEmpty;
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Restaurant r) async {
    if (_database == null) await _initDatabase();

    final isFav = await isFavorite(r);

    if (isFav) {
      await _database!.delete(
        'favorites',
        where: 'name = ?',
        whereArgs: [r.name],
      );
    } else {
      await _database!.insert(
        'favorites',
        {'name': r.name},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await fetchFavorites();
  }

  // Fetch all favorite restaurants
  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_database == null) await _initDatabase();

      // Get all favorite names from database
      final List<Map<String, dynamic>> favMaps = await _database!.query('favorites');
      final Set<String> favNames = favMaps.map((map) => map['name'] as String).toSet();

      // Get all restaurants and filter favorites
      final all = await _repo.fetchRestaurants();
      favorites = all.where((r) => favNames.contains(r.name)).toList();

      // Emit updated favorites to the stream
      _favoritesStreamController.add(favorites);
    } catch (e) {
      favorites = [];
      print("Error cargando favoritos: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Close the database when done
  Future<void> close() async {
    await _database?.close();
    await _favoritesStreamController.close();
  }
}