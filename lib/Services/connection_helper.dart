import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) return false;


    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 3),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
}