import 'dart:convert';
import 'dart:isolate';
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
      print("🔍 ANALYTICS RESPONSE: ${response.body}");
      // Procesar JSON en un isolate para no bloquear la UI
      return await _processInIsolate(response.body);
    } else {
      throw Exception("Error fetching most-liked restaurants. Status: ${response.statusCode}");
    }
  }

  Future<List<String>> _processInIsolate(String responseBody) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _parseMostLikedRestaurantsIsolate,
      _IsolateData(receivePort.sendPort, responseBody),
    );

    final result = await receivePort.first;
    return result as List<String>;
  }

  static void _parseMostLikedRestaurantsIsolate(_IsolateData data) {
    try {
      final jsonData = json.decode(data.jsonData) as Map<String, dynamic>;

      if (!jsonData.containsKey("analytics")) {
        throw Exception("Missing 'analytics' key in response");
      }

      final List<dynamic> analyticsList = jsonData["analytics"];
      if (analyticsList.isEmpty) {
        data.sendPort.send(<String>[]);
        return;
      }

      // Ordenar los registros por mes (descendente) para encontrar el más reciente
      analyticsList.sort((a, b) => b["mes"].compareTo(a["mes"]));
      final Map<String, dynamic> latestEntry = analyticsList.first;

      if (!latestEntry.containsKey("topRestaurantes")) {
        throw Exception("Missing 'topRestaurantes' key in latest analytics entry");
      }

      final List<dynamic> top = latestEntry["topRestaurantes"];

      //  Ordenar explícitamente por visitas (mayor a menor)
      top.sort((a, b) => (b["totalVisits"] as int).compareTo(a["totalVisits"] as int));

      final result = top
          .take(5)
          .map<String>((item) => item["restaurantName"].toString())
          .toList();

      
      data.sendPort.send(result);
    } catch (e) {
      data.sendPort.send(<String>[]);
    }
  }
}

class _IsolateData {
  final SendPort sendPort;
  final String jsonData;

  _IsolateData(this.sendPort, this.jsonData);
}
