import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class FavoritesViewModel extends ChangeNotifier {
  final RestaurantRepository _repo = RestaurantRepository();
  bool isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<Restaurant> _allFavorites = [];

  List<Restaurant> get favorites => _allFavorites.take(_currentPage * _itemsPerPage).toList();
  bool get hasMoreItems => _allFavorites.length > _currentPage * _itemsPerPage;

  // Stream for favorites
  final StreamController<List<Restaurant>> _favoritesStreamController =
  StreamController<List<Restaurant>>.broadcast();
  Stream<List<Restaurant>> get favoritesStream => _favoritesStreamController.stream;


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

  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_database == null) await _initDatabase();

      final List<Map<String, dynamic>> favMaps = await _database!.query('favorites');
      final Set<String> favNames = favMaps.map((map) => map['name'] as String).toSet();

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('restaurants_cache');

      List<Restaurant> all = [];
      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        all = jsonData.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        all = [];
      }

      _allFavorites = all.where((r) => favNames.contains(r.name)).toList();
      _currentPage = 1;

      // Emit updated favorites to the stream
      _favoritesStreamController.add(_allFavorites);
    } catch (e) {
      _allFavorites = [];
      print("Error cargando favoritos: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreFavorites() {
    if (hasMoreItems) {
      _currentPage++;
      notifyListeners();
    }
    return Future.value();
  }

  // Close the database when done
  Future<void> close() async {
    await _database?.close();
    await _favoritesStreamController.close();
  }
}