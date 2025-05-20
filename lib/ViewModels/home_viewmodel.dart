import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ConnectivityService _connectivityService = ConnectivityService();

  static const _cacheKey = 'restaurants_cache';
  static const _cacheDurationKey = 'restaurants_cache_timestamp';

  Set<String> _favorites = {};
  List<Restaurant> _allRestaurants = [];
  bool _isLoading = true;
  bool _isOffline = false;
  Database? _database;

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;
  List<Restaurant> get restaurants => _allRestaurants.take(_currentPage * _itemsPerPage).toList();
  bool get hasMoreItems => _allRestaurants.length > _currentPage * _itemsPerPage;

  HomeViewModel() {
    _initDatabase();
    _loadFavorites();
    loadRestaurants(); // Cargar datos al iniciar
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'favorites_database.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE favorites (name TEXT PRIMARY KEY)');
      },
    );
  }

  Future<void> _loadFavorites() async {
    if (_database == null) await _initDatabase();

    try {
      final List<Map<String, dynamic>> maps = await _database!.query('favorites');
      _favorites = maps.map((map) => map['name'] as String).toSet();
      notifyListeners();
    } catch (e) {
      print("Error loading favorites: $e");
      _favorites = {};
    }
  }

  Future<void> toggleFavorite(Restaurant r) async {
    if (_database == null) await _initDatabase();

    try {
      if (_favorites.contains(r.name)) {
        _favorites.remove(r.name);
        await _database!.delete('favorites', where: 'name = ?', whereArgs: [r.name]);
      } else {
        _favorites.add(r.name);
        await _database!.insert('favorites', {'name': r.name},
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      notifyListeners();
    } catch (e) {
      print("Error updating favorite: $e");
    }
  }

  Future<void> loadRestaurants({bool loadMore = false}) async {
    if (!loadMore) {
      _isLoading = true;
      _currentPage = 1;
      notifyListeners();
    }

    try {
      final isConnected = await _connectivityService.isConnected();
      final prefs = await SharedPreferences.getInstance();
      _isOffline = !isConnected;

      if (isConnected) {
        await _loadFromNetwork(prefs);
      } else {
        await _loadFromCache(prefs);
      }
    } catch (e) {
      print("Error loading restaurants: $e");
      final prefs = await SharedPreferences.getInstance();
      await _loadFromCache(prefs);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromNetwork(SharedPreferences prefs) async {
    try {
      _allRestaurants = await _restaurantRepository.fetchRestaurants();

      // Actualizar caché
      final cacheData = _allRestaurants.take(5).map((r) => r.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(cacheData));
      await prefs.setInt(_cacheDurationKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print("Error loading from network: $e");
      throw e;
    }
  }

  Future<void> loadMoreItems() async {
    if (hasMoreItems) {
      _isLoadingMore = true;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 500)); // Simular carga
      _currentPage++;

      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache(SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        _allRestaurants = jsonData.map((json) => Restaurant.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error loading from cache: $e");
      _allRestaurants = [];
    }
  }
}