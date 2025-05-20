import '../Models/restaurant_model.dart';
import '../ServiceAdapters/analytics_service_adapter.dart';
import '../ServiceAdapters/backend_service_adapter.dart';
import 'package:http/http.dart' as http;

class RecommendedRepository {
  final backend = BackendServiceAdapterImpl(
    baseUrl: "http://34.60.49.32:8000", 
    client: http.Client(),
  );

  final analytics = AnalyticsServiceAdapterImpl(
    baseUrl: "http://34.56.108.17:8000",
    client: http.Client(),
  );

  Future<List<Restaurant>> getRecommendedRestaurants() async {
    try {
      final topNames = await analytics.getMostLikedRestaurantNames(); 
      final allRestaurants = await backend.fetchRestaurants();

      return allRestaurants
          .where((r) => topNames.contains(r.name))
          .toList();
    } catch (e) {
      print("Error en RecommendedRepository: $e");
      return [];
    }
  }
}
