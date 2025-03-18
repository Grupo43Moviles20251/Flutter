import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  List<Restaurant> restaurants = [];
  bool isLoading = true;

  Future<void> loadRestaurants() async {
    isLoading = true;
    notifyListeners(); // Notifica a la vista para mostrar el loader

    // Imprime en consola para verificar
    print("Cargando restaurantes...");

    restaurants = await _restaurantRepository.fetchRestaurants();

    // Imprime los restaurantes cargados
    print("Restaurantes cargados: ${restaurants.length}");

    isLoading = false;
    notifyListeners(); // Actualiza la UI
  }

}
