import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/restaurant_model.dart';

abstract class MapRepository {

  Future<List<Restaurant>> fetchRestaurants();
}


class mapRepository implements MapRepository {
  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('http://192.168.0.134:8000/restaurants'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching restaurants');
    }
  }
  
}