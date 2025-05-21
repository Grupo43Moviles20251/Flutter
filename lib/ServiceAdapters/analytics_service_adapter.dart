import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class AnalyticsServiceAdapter {
  Future<List<String>> getMostLikedRestaurantNames();
}


class AnalyticsServiceAdapterImpl implements AnalyticsServiceAdapter {
  final String baseUrl;
  final http.Client client;

  AnalyticsServiceAdapterImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<List<String>> getMostLikedRestaurantNames() async {
    final url = Uri.parse('$baseUrl/analytics/most-liked-restaurants');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      print("🔍 ANALYTICS RESPONSE: ${response.body}"); // 👈 debug

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (!jsonData.containsKey("analytics")) {
        throw Exception("Missing 'analytics' key in response");
      }

      final List<dynamic> analyticsList = jsonData["analytics"];
      if (analyticsList.isEmpty) return [];

      final Map<String, dynamic> latestEntry = analyticsList.last;

      if (!latestEntry.containsKey("topRestaurantes")) {
        throw Exception("Missing 'topRestaurantes' key in latest analytics entry");
      }

      final List<dynamic> top = latestEntry["topRestaurantes"];
      return top
          .take(5)
          .map<String>((item) => item["restaurantName"].toString())
          .toList();
    } else {
      throw Exception("Error fetching most-liked restaurants. Status: ${response.statusCode}");
    }
  }


}
