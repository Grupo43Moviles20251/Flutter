import '../Repositories/restaurant_detail_repository.dart';

class RestaurantDetailViewModel {
  final RestaurantDetailRepository _repository = restaurantDetailRepository();

  Future<String?> orderItem(int itemId, int quantity) async {
    try {
      final result = await _repository.orderItem(itemId, quantity);

      return result;
    } catch (e) {
      return "Error";
    }
  }
}