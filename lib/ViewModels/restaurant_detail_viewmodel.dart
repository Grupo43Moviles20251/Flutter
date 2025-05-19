import '../Repositories/restaurant_detail_repository.dart';

class RestaurantDetailViewModel {
  final RestaurantDetailRepository _repository = restaurantDetailRepository();
  Future<String?> orderItem( itemId, int quantity) async {

    try {
      final result = await _repository.orderItem(itemId, quantity);

      return result;
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