import 'package:first_app/Repositories/order_repository.dart';
import 'package:first_app/ViewModels/order_viewmodel.dart';

import '../Models/order_model.dart';
import '../Repositories/restaurant_detail_repository.dart';

class RestaurantDetailViewModel {
  final RestaurantDetailRepository _repository = restaurantDetailRepository();
  final OrderViewModel _orderViewModel = OrderViewModel(orderRepository: OrderRepositoryImpl());
  Future<String?> orderItem(int itemId, int quantity,
     String productName,
        double price) async {
    try {
      final orderCode = await _repository.orderItem(itemId, quantity);

      if (orderCode != null && orderCode != "Error") {
        // Crear objeto Order
        final order = OrderModel(
          orderId: orderCode,
          productId: itemId.toString(),
          productName: productName,
          quantity: quantity,
          price: price,
          orderDate: DateTime.now().toString(),
          status: 'pending',
        );

        // Guardar el pedido
        await _orderViewModel.saveOrder(order);

        // Enviar analytics
        await _repository.sendOrderAnalytics(itemId, productName, quantity);

        return orderCode;
      }
      return "Error";
    } catch (e) {
      return "Error";
    }
  }

  Future<String?> sendOrderAnalitycs(int productId,String productName, int quantity) async {

    try {
      await _repository.sendOrderAnalytics(productId,productName, quantity);
      return "Success";
    } catch (e) {
      return "Error";
    }
  }

  Future<void> logDirections(String productId) {
    return _repository.logDetailEvent(productId, 'directions');
  }

  Future<void> logDetailEvent(String productId, String eventType) {
    print("Sending logDetailEvent: $productId - $eventType");
  return _repository.logDetailEvent(productId, eventType);
}

}