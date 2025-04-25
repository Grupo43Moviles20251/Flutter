import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Repositories/restaurant_detail_repository.dart';

class RestaurantDetailViewModel {
  final RestaurantDetailRepository _repository = restaurantDetailRepository();
  final ConnectivityService _connectivityService = ConnectivityService();
  Future<String?> orderItem(BuildContext context, itemId, int quantity) async {

    final isConnected = await _connectivityService.isConnected();
    if(!isConnected){
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection. Try again order when you\'re back online.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return 'No Internet Connection';
    }
    try {
      final result = await _repository.orderItem(itemId, quantity);

      return result;
    } catch (e) {
      return "Error";
    }
  }
}