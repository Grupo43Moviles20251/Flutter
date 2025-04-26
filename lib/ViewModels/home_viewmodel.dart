import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON serialization
import 'dart:async'; // For Isolate and async operations
import 'dart:isolate';

import 'package:sqflite/sqflite.dart'; // For Isolate usage

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ConnectivityService connectivityService = ConnectivityService();
  static const _cacheKey = 'restaurants_cache';
  static const _cacheDurationKey = 'restaurants_cache_timestamp';
  static const _cacheDuration = Duration(hours: 1); // Cache expires after 1 hour

  Set<String> _favorites = {};
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  bool isOffline = false;
  static Database? _database;

  bool isFavorite(Restaurant r) => _favorites.contains(r.name);

  final StreamController<List<Restaurant>> _restaurantsStreamController = StreamController<List<Restaurant>>.broadcast();
  Stream<List<Restaurant>> get restaurantsStream => _restaurantsStreamController.stream;

  HomeViewModel() {
    _initDatabaseConnection().then((_) => _loadFavorites());
  }

  Future<void> _initDatabaseConnection() async {
    _database ??= await openDatabase(
        join(await getDatabasesPath(), 'favorites_database.db'),
        version: 1,
        // No necesitamos onCreate porque la tabla ya existe
      );
  }

  // Cargar favoritos desde la tabla existente
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

  Future<void> loadRestaurants() async {
    isLoading = true;
    notifyListeners();

    final isConnected = await connectivityService.isConnected();
    final prefs = await SharedPreferences.getInstance();

    if (isConnected) {
      isOffline = false;
      try {
        // Fetch fresh data from network
        restaurants = await _restaurantRepository.fetchRestaurants();

        // Emit the data to the stream
        _restaurantsStreamController.add(restaurants);

        // Cache the new data
        final cacheData = restaurants.map((r) => r.toJson()).toList();
        await prefs.setString(_cacheKey, json.encode(cacheData));
        await prefs.setInt(_cacheDurationKey, DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        print("Error al cargar restaurantes: $e");
        // If network fails, try to load from cache
        await _loadFromCache(prefs);
      }
    } else {
      isOffline = true;
      // Load from cache when offline
      await _loadFromCache(prefs);
    }

    isLoading = false;
    notifyListeners();
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
        restaurants = jsonData.map((json) => Restaurant.fromJson(json)).toList();
        _restaurantsStreamController.add(restaurants);
      } else {
        restaurants = [];
        _restaurantsStreamController.add(restaurants); // Emit empty list if no cache
      }
    } catch (e) {
      print("Error loading from cache: $e");
      restaurants = [];
      _restaurantsStreamController.add(restaurants);
    }
  }

  // Isolate for processing restaurant data in background
  Future<void> processRestaurantsInBackground(List<Restaurant> data) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_filterRestaurants, receivePort.sendPort);
    final sendPort = await receivePort.first;

    final resultPort = ReceivePort();
    sendPort.send([resultPort.sendPort, data]);
    final result = await resultPort.first;

    // Update restaurants list
    restaurants = List<Restaurant>.from(result);
    notifyListeners();
  }

  static void _filterRestaurants(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final data = await receivePort.first;
    List<Restaurant> filteredRestaurants = data[1]
        .where((r) => r.rating > 4.0) // Just an example filter
        .toList();

    sendPort.send(filteredRestaurants);
  }

  Future<void> close() async {
    await _restaurantsStreamController.close();
  }
}
