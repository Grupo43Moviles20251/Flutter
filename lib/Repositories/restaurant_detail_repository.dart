import 'package:http/http.dart' as http;

import '../ServiceAdapters/backend_service_adapter.dart';

abstract class RestaurantDetailRepository {
  Future<String?> orderItem(int email, int password);

}

class restaurantDetailRepository implements RestaurantDetailRepository{
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://157.253.206.172:8000', client: http.Client());

  @override
  Future<String?> orderItem(int itemId, int quantity) {
    return backendServiceAdapter.orderItem(itemId,quantity);
  }



}