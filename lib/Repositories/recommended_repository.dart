import '../Models/restaurant_model.dart';
import '../ServiceAdapters/analytics_service_adapter.dart';
import '../ServiceAdapters/backend_service_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecommendedRepository {
  final backend = BackendServiceAdapterImpl(

  );

  final analytics = AnalyticsServiceAdapterImpl(
    baseUrl: "http://34.56.108.17:8000",
    client: http.Client(),
  );

  Future<List<Restaurant>> getRecommendedRestaurants() async {
    try {
      final topNames = await analytics.getMostLikedRestaurantNames(); 
      final allRestaurants = await backend.fetchRestaurants();

      final topRestaurants = topNames
          .map((name) => allRestaurants.firstWhere((r) => r.name == name))
          .toList();

      final top3 = topRestaurants.take(3).toList(); // 🔥 Top 3

      //Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(top3.map((r) => r.toJson()).toList());
      await prefs.setString("top3_recommended", encoded);

      return topRestaurants;
    } catch (e) {
      print("Error en RecommendedRepository: $e");
      return [];
    }
  }

  Future<List<Restaurant>> getTop3FromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("top3_recommended");
    if (jsonString == null) return [];

    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Restaurant.fromJson(e)).toList();
    } catch (e) {
      print("Error decoding cached top 3: $e");
      return [];
    }
  }
}
