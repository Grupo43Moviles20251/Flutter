// repositories/order_repository.dart
import 'package:first_app/Models/order_model.dart';
import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OrderRepository {
  Future<void> saveOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
}

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseServiceAdapter firebaseService = FirebaseServiceAdapterImpl();
  late final SharedPreferences sharedPreferences;

  OrderRepositoryImpl() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }


  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    try {
      await _initPrefsIfNeeded();
      final userId = _getCurrentUserId();
      print("Se llega al save order");

      if (userId != null) {

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(order.orderId)
            .set(order.toMap());
      }

      await _saveOrderToCache(order);
    } catch (e) {
      print('Error saving order: $e');
      await _saveOrderToCache(order);
    }
  }

  Future<void> _initPrefsIfNeeded() async {
    try {
      if (sharedPreferences == null) {
        await _initPrefs();
      }
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }

  Future<void> _saveOrderToCache(OrderModel order) async {
    await _initPrefsIfNeeded();
    final orders = await getOrdersFromCache();
    orders.add(order);
    await sharedPreferences.setString(
      'cached_orders',
      jsonEncode(orders.map((o) => o.toMap()).toList()),
    );
  }

  Future<List<OrderModel>> getOrdersFromCache() async {
    await _initPrefsIfNeeded();
    final cachedData = sharedPreferences.getString('cached_orders');
    if (cachedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((json) => OrderModel.fromMap(json)).toList();
      } catch (e) {
        print('Error parsing cached orders: $e');
        return [];
      }
    }
    return [];
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    await _initPrefsIfNeeded();
    final userId = _getCurrentUserId();

    try {
      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .get();

        final orders = snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList();

        await sharedPreferences.setString(
          'cached_orders',
          jsonEncode(orders.map((o) => o.toMap()).toList()),
        );

        return orders;
      }
      return await getOrdersFromCache();
    } catch (e) {
      print('Error fetching orders: $e');
      return await getOrdersFromCache();
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _initPrefsIfNeeded();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc(orderId)
            .update({'status': newStatus});
      }

      final orders = await getOrdersFromCache();
      final updatedOrders = orders.map((order) {
        if (order.orderId == orderId) {
          return OrderModel(
            orderId: order.orderId,
            productId: order.productId,
            productName: order.productName,
            quantity: order.quantity,
            price: order.price,
            orderDate: order.orderDate,

            status: newStatus,
          );
        }
        return order;
      }).toList();

      await sharedPreferences.setString(
        'cached_orders',
        jsonEncode(updatedOrders.map((o) => o.toMap()).toList()),
      );
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}