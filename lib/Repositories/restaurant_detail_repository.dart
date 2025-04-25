import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:http/http.dart' as http;

import '../ServiceAdapters/backend_service_adapter.dart';

abstract class RestaurantDetailRepository {
  Future<String?> orderItem(int email, int password);
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity);

}

class restaurantDetailRepository implements RestaurantDetailRepository{
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://34.60.49.32:8000', client: http.Client());
   final FirebaseServiceAdapter firebaseServiceAdapter = FirebaseServiceAdapterImpl();
  @override
  Future<String?> orderItem(int itemId, int quantity) {
    return backendServiceAdapter.orderItem(itemId,quantity);
  }

  @override
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity) {
    return firebaseServiceAdapter.sendOrderAnalytics(productId, nameProduct, quantity);
  }



}