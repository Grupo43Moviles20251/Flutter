import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/ServiceAdapters/backend_service_adapter.dart';

class RestaurantRepository {
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl();


  // Obtener todos los restaurantes
  Future<List<Restaurant>> fetchRestaurants() async {
    return backendServiceAdapter.fetchRestaurants();
  }


  // Buscar restaurantes por tipo (Restaurantes, Cafés, Supermercados)
  Future<List<Restaurant>> fetchRestaurantsByType(int type) async {
    return backendServiceAdapter.fetchRestaurantsByType(type);
  }

  // Buscar restaurantes o productos por texto
  Future<List<Restaurant>> searchRestaurants(String query, {int? type}) async {
    return backendServiceAdapter.searchRestaurants(query, type: type);
  }
}
