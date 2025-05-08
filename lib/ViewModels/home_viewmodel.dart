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
  static const _cacheDuration = Duration(hours: 1);

  Set<String> _favorites = {};
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  bool _isOffline = false;
  Database? _database;
  String? _errorMessage;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

  HomeViewModel() {
    _initDatabase();
    _loadFavorites();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'favorites_database.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE favorites (name TEXT PRIMARY KEY)',
        );
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
      print("Error updating favorite: $e");
    }
  }

  Future<void> loadRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.isConnected();
      final prefs = await SharedPreferences.getInstance();

      if (isConnected) {
        _isOffline = false;
        await _loadFromNetwork(prefs);
      } else {
        _isOffline = true;
        await _loadFromCache(prefs);
      }
    } catch (e) {
      _errorMessage = "Failed to load data: ${e.toString()}";
      print("Error loading restaurants: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromNetwork(SharedPreferences prefs) async {
    try {
      _restaurants = await _restaurantRepository.fetchRestaurants();

      // Update cache
      final cacheData = _restaurants.map((r) => r.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(cacheData));
      await prefs.setInt(_cacheDurationKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // If network fails, try cache
      await _loadFromCache(prefs);
      throw e; // Re-throw to be caught by outer catch
    }
  }

  Future<void> _loadFromCache(SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKey);
      final cachedTimestamp = prefs.getInt(_cacheDurationKey) ?? 0;
      final cacheAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedTimestamp)
      );

      if (cachedData != null && cacheAge < _cacheDuration) {
        final List<dynamic> jsonData = json.decode(cachedData);
        _restaurants = jsonData.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        _restaurants = [];
        _errorMessage = "No cached data available";
      }
    } catch (e) {
      _restaurants = [];
      _errorMessage = "Error loading cached data";
      print("Error loading from cache: $e");
    }
  }
}