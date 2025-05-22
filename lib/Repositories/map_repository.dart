import '../Models/restaurant_model.dart';
import '../ServiceAdapters/backend_service_adapter.dart';

abstract class MapRepository {

  Future<List<Restaurant>> fetchRestaurants();
}

class mapRepository implements MapRepository {
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl();

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      return backendServiceAdapter.fetchRestaurants();
    } catch(e){
      return [];
    }
    }
  
}