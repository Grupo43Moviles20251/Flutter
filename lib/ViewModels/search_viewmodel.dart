import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:flutter/material.dart';

class SearchViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  List<Restaurant> restaurants = [];
  bool isLoading = true;

  // Cargar todos los restaurantes al inicio
  Future<void> loadAllRestaurants() async {
    isLoading = true;
    notifyListeners();  // Notifica para mostrar el loader

    try {
      // Imprimir para verificar que se están cargando los restaurantes
      print("Cargando todos los restaurantes...");

      restaurants = await _restaurantRepository.fetchRestaurants();
      print("Restaurantes cargados: ${restaurants.length}");

    } catch (e) {
      print("Error al cargar restaurantes: $e");
    }

    isLoading = false;
    notifyListeners();  // Actualiza la UI
  }

  // Filtro de búsqueda
  Future<void> searchRestaurants(String query, {int? type}) async {
    isLoading = true;
    notifyListeners();

    try {
      // Llamada al API de búsqueda con el filtro de tipo si se pasa
      restaurants = await _restaurantRepository.searchRestaurants(query, type: type);
    } catch (e) {
      print("Error buscando restaurantes: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
