import 'package:flutter/material.dart';
import '../Models/restaurant_model.dart';
import '../Repositories/recommended_repository.dart';
import 'package:sqflite/sqflite.dart';

class RecommendedViewModel extends ChangeNotifier {
  final RecommendedRepository _repository = RecommendedRepository();
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;
  bool isLoading = false;

  // 🔧 Favoritos locales
  Set<String> _favorites = {};
  Database? _database;

  RecommendedViewModel() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'favorites_database.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE favorites (name TEXT PRIMARY KEY)');
      },
    );
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> maps = await _database!.query('favorites');
    _favorites = maps.map((map) => map['name'] as String).toSet();
    notifyListeners();
  }

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

  Future<void> toggleFavorite(Restaurant r) async {
    if (_database == null) return;
    if (_favorites.contains(r.name)) {
      _favorites.remove(r.name);
      await _database!.delete('favorites', where: 'name = ?', whereArgs: [r.name]);
    } else {
      _favorites.add(r.name);
      await _database!.insert('favorites', {'name': r.name},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    notifyListeners();
  }

  Future<void> loadRecommended() async {
    isLoading = true;
    notifyListeners();

    _restaurants = await _repository.getRecommendedRestaurants();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadTop3FromCache() async {
    _restaurants = await _repository.getTop3FromCache();
    notifyListeners();
  }
}
