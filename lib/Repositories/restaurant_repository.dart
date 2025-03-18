import 'dart:convert';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:http/http.dart' as http;

class RestaurantRepository {
  final String apiUrl = "http://192.168.15.13:8000/restaurants"; // URL del backend

  // Obtener todos los restaurantes
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Verifica si la respuesta es válida
        print("Respuesta de la API: ${response.body}");

        // Si la respuesta está vacía o es nula, lanza una excepción
        if (response.body.isEmpty) {
          throw Exception("La respuesta de la API está vacía");
        }

        // Intenta decodificar el cuerpo de la respuesta
        List<dynamic> jsonList = json.decode(response.body);

        // Verifica que jsonList no sea nulo
        print("Datos de restaurantes: ${jsonList}");

        // Mapea los datos a una lista de objetos Restaurant
        return jsonList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        // Si el estado no es 200, lanza una excepción
        throw Exception("Error al obtener restaurantes. Código de estado: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en fetchRestaurants: $e");
      return [];
    }
  }

  // Buscar restaurantes por tipo (Restaurantes, Cafés, Supermercados)
  Future<List<Restaurant>> fetchRestaurantsByType(int type) async {
    try {
      var response = await http.get(Uri.parse('$apiUrl/type/$type'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception("Error al obtener restaurantes por tipo");
      }
    } catch (e) {
      print("Error al buscar restaurantes por tipo: $e");
      return [];
    }
  }

  // Buscar restaurantes o productos por texto
  Future<List<Restaurant>> searchRestaurants(String query, {int? type}) async {
    try {
      String url = '$apiUrl/search/$query';
      
      // Si se pasa el parámetro 'type', agrega el filtro a la URL
      if (type != null) {
        url = '$apiUrl/type/$type';  // Cambia la URL si se aplica un filtro por tipo
      }

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception("Error al buscar restaurantes");
      }
    } catch (e) {
      print("Error en searchRestaurants: $e");
      return [];
    }
  }
}
