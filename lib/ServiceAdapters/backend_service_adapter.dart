import 'dart:async';
import 'dart:convert';
import 'dart:isolate';  // Importante para trabajar con Isolates
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
  final String baseUrl = 'http://34.60.49.32:8000';
  late final http.Client _client;
  Timer? _connectionCleanupTimer;

  BackendServiceAdapterImpl() : _client = http.Client() {
    // Configurar un timer para cerrar conexiones inactivas después de un tiempo
    _connectionCleanupTimer = Timer.periodic(Duration(minutes: 10), (_) {
      _client.close();
      _client = http.Client();
    });
  }

  @override
  void dispose() {
    _connectionCleanupTimer?.cancel();
    _client.close();
  }


  Future<http.Response> _sendRequest(
      String method,
      String endpoint, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      switch (method.toLowerCase()) {
        case 'get':
          return await _client.get(uri, headers: requestHeaders);
        case 'post':
          return await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      print('Request error: $e');
      throw Exception('Network error occurred');
    }
  }

  @override
  Future<UserDTO> getUserProfile(String token) async {
    final response = await _sendRequest(
      'get',
      'users/me',
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return UserDTO.fromJson(json.decode(response.body));
    } else {
      throw Exception('No connection with the server: ${response.statusCode}');
    }
  }

  @override
  Future<UserDTO> createUser(UserDTO user, String token) async {
    final response = await _sendRequest(
      'post',
      'signup',
      headers: {'Authorization': 'Bearer $token'},
      body: user.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserDTO.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('This email is already registered');
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }


  // Usamos Isolates para procesar grandes cantidades de datos sin bloquear la UI
  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await _sendRequest('get', 'restaurants');

      if (response.statusCode == 200) {
        return await _processInIsolate(response.body);
      } else {
        throw Exception('Error fetching restaurants: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetchRestaurants: $e");
      return [];
    }
  }
  Future<List<Restaurant>> _processInIsolate(String jsonData) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _parseRestaurantsJson,
      _IsolateData(receivePort.sendPort, jsonData),
    );

    // Get the processed data from the isolate
    final restaurants = await receivePort.first;
    return restaurants as List<Restaurant>;
  }

  static void _parseRestaurantsJson(_IsolateData data) {
    try {
      // Parse JSON in the isolate
      final jsonList = json.decode(data.jsonData) as List;
      final restaurants = jsonList.map((json) => Restaurant.fromJson(json)).toList();

      // Send result back to main isolate
      data.sendPort.send(restaurants);
    } catch (e) {
      // Send empty list if error occurs
      data.sendPort.send(<Restaurant>[]);
    }
  }

  @override
  Future<List<Restaurant>> fetchRestaurantsByType(int type) async {
    try {
      final response = await _sendRequest('get', 'type/$type');

      if (response.statusCode == 200) {
        return await _processInIsolate(response.body);
      } else {
        throw Exception('Error fetching restaurants by type: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetchRestaurantsByType: $e");
      return [];
    }
  }


  @override
  Future<List<Restaurant>> searchRestaurants(String query, {int? type}) async {
    try {
      final endpoint = type != null
          ? 'restaurants/type/$type'
          : 'restaurants/search/$query';

      final response = await _sendRequest('get', endpoint);

      if (response.statusCode == 200) {
        return await _processInIsolate(response.body);
      } else {
        throw Exception('Error searching restaurants: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in searchRestaurants: $e");
      return [];
    }
  }


  @override
  Future<String> signUp(String name, String email, String password, String address, String birthday) async {
    try {
      final response = await _sendRequest(
        'post',
        'signup',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'birthday': birthday,
        },
      );

      if (response.statusCode == 200) {
        return "Success";
      } else {
        return "Could not create the user: ${response.statusCode}";
      }
    } catch (e) {
      return "Error creating the user: $e";
    }
  }

  @override
  Future<String> orderItem(int itemId, int quantity) async {
    try {
      final response = await _sendRequest(
        'post',
        'order',
        body: {
          'product_id': itemId,
          'quantity': quantity
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final claimCode = data['code'];
        return claimCode;
      } else {
        return "Could not order the item: ${response.statusCode}";
      }
    } catch (e) {
      return "Error ordering the item: $e";
    }
  }

  

}

class _IsolateData {
  final SendPort sendPort;
  final String jsonData;

  _IsolateData(this.sendPort, this.jsonData);
}
