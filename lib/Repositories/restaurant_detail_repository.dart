import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';

import '../ServiceAdapters/backend_service_adapter.dart';

abstract class RestaurantDetailRepository {
  Future<String?> orderItem(int email, int password);
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity);
  Future<void> logDetailEvent(String restaurantId, String eventType);

}

class restaurantDetailRepository implements RestaurantDetailRepository{
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl();
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
    return firebaseServiceAdapter.logDetailEvent(productId, eventType);
  }

}