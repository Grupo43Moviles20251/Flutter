import 'dart:convert';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:http/http.dart' as http;

class RestaurantRepository {
  final String apiUrl = "http://192.168.15.13:8000/restaurants"; // URL del backend

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

}
