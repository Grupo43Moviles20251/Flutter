import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsService {
  final String apiUrl = "http://34.56.108.17:8000/analyticspages"; // URL de tu API

  Future<void> trackScreenTime(String screenName, int durationInSeconds) async {
    final Map<String, dynamic> data = {
      "screen_name": screenName,
      "duration": durationInSeconds,
      "timestamp": DateTime.now().toIso8601String(),
    };


    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print(response.statusCode );
    print(data);

    if (response.statusCode != 200) {
      print(response.body);
      throw Exception("Error al enviar datos a la API");
    }
  }
}