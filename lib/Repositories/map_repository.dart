import 'package:http/http.dart' as http;
import '../Models/restaurant_model.dart';
import '../ServiceAdapters/backend_service_adapter.dart';

abstract class MapRepository {

  Future<List<Restaurant>> fetchRestaurants();
}

class mapRepository implements MapRepository {
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://192.168.20.48:8000', client: http.Client());

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      return backendServiceAdapter.fetchRestaurants();
    } catch(e){
      return [];
    }
    }
  
}