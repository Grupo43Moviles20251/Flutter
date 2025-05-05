import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:http/http.dart' as http;

import '../ServiceAdapters/backend_service_adapter.dart';

abstract class RestaurantDetailRepository {
  Future<String?> orderItem(int email, int password);
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity);
  Future<void> logDetailEvent(String restaurantId, String eventType);

}

class restaurantDetailRepository implements RestaurantDetailRepository{
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://192.168.20.48:8000', client: http.Client());
   final FirebaseServiceAdapter firebaseServiceAdapter = FirebaseServiceAdapterImpl();
  @override
  Future<String?> orderItem(int itemId, int quantity) {
    return backendServiceAdapter.orderItem(itemId,quantity);
  }

  @override
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity) {
    return firebaseServiceAdapter.sendOrderAnalytics(productId, nameProduct, quantity);
  }

  @override
  Future<void> logDetailEvent(String productId, String eventType) {
    return backendServiceAdapter.logDetailEvent(productId, eventType);
  }

}