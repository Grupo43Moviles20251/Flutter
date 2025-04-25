import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:http/http.dart' as http;
import '../Dtos/user_dto.dart';

abstract class BackendServiceAdapter {

  Future<UserDTO> getUserProfile(String token);
  Future<UserDTO> createUser(UserDTO user, String token);

  Future<List<Restaurant>> fetchRestaurants();
  Future<List<Restaurant>> fetchRestaurantsByType(int type);
  Future<List<Restaurant>> searchRestaurants(String query, {int? type});

  Future<String> signUp(String name, String email, String password, String address, String birthday);

  Future<String> orderItem(int itemId, int quantity);
}


class BackendServiceAdapterImpl implements BackendServiceAdapter {

  final String baseUrl;
  final http.Client client;


  BackendServiceAdapterImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<UserDTO> getUserProfile(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {

      return UserDTO.fromJson(json.decode(response.body));
    } else {
      throw Exception('No connection with the server: ${response.statusCode}');
    }
  }

  @override
  Future<UserDTO> createUser(UserDTO user, String token) async {
    final response = await client.post(
      Uri.parse('$baseUrl/signup'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserDTO.fromJson(json.decode(response.body));
    } else if(response.statusCode == 409){
      throw Exception('This email is already registered');
    }
    else {
      throw Exception('Failed to create user');
    }
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      }
      else {
        throw Exception('Error fetching restaurants');
      }
    } catch(e){
      return [];
    }
  }

  @override
  Future<List<Restaurant>> fetchRestaurantsByType(int type) async{
    try {
      print(type);
      var response = await http.get(Uri.parse('$baseUrl/type/$type'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception("Error al obtener restaurantes por tipo");
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Restaurant>> searchRestaurants(String query, {int? type}) async {
    try {
      String url = '$baseUrl/restaurants/search/$query';

      if (type != null) {
        url = '$baseUrl/restaurants/type/$type';
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

  Future<List<String>> getFavoriteRestaurantIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favoriteIds = prefs.getStringList('favorite_restaurants');
    return favoriteIds ?? [];
  }

  Future<void> addFavoriteRestaurant(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favorite_restaurants') ?? [];
    if (!favoriteIds.contains(restaurantId)) {
      favoriteIds.add(restaurantId);
      await prefs.setStringList('favorite_restaurants', favoriteIds);
    }
  }

  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favorite_restaurants') ?? [];
    favoriteIds.remove(restaurantId);
    await prefs.setStringList('favorite_restaurants', favoriteIds);
  }

  @override
  Future<String> signUp(String name, String email, String password, String address, String birthday) async {
    try{
      var response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'birthday': birthday,
        }),
      );

      if (response.statusCode == 200){
        return "Success";

      }else if (response.statusCode == 400) {
        return "This email is already in use";

      }else{
        print(response.statusCode);
        return "Could not create the user";
      }
    } catch(e){

      return "Error creating the user";

    }
  }

  @override
  Future<String> orderItem(int itemId, int quantity) async {
    try{

      var response = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_id': itemId,
          'quantity': quantity
        }),
      );


      if (response.statusCode == 200){
        final data = jsonDecode(response.body);
        final claimCode = data['code'];
        return claimCode;

      }else{
        return "Could not order the item";
      }
    } catch(e){

      return "Error ordering the item";

    }
  }

}
