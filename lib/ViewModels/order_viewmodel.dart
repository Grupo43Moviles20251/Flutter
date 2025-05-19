import 'package:first_app/Models/order_model.dart';
import 'package:first_app/Repositories/order_repository.dart';

class OrderViewModel {
  final OrderRepository orderRepository;

  OrderViewModel({required this.orderRepository});

  Future<void> saveOrder(OrderModel order) async {
    await orderRepository.saveOrder(order);
  }

  Future<List<OrderModel>> getOrders() async {
    return await orderRepository.getOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await orderRepository.updateOrderStatus(orderId, newStatus);
  }
}