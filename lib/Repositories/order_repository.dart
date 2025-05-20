import 'dart:isolate';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:first_app/Models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ServiceAdapters/firebase_service_adapter.dart';

abstract class OrderRepository {
  Future<void> saveOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
}

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseServiceAdapter firebaseService = FirebaseServiceAdapterImpl();
  static Database? _database;
  static const String _tableName = 'orders';
  static const int _maxCachedOrders = 10;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'orders.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            orderId TEXT PRIMARY KEY,
            productId TEXT,
            productName TEXT,
            quantity INTEGER,
            price REAL,
            orderDate TEXT,
            status TEXT,
            statusUpdatedAt TEXT,
            cancelledAt TEXT,
            cancelledBy TEXT
          )
        ''');
      },
    );
  }


  Future<List<OrderModel>> _parseOrdersInIsolate(List<Map<String, dynamic>> rawData) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_orderParsingIsolate, [receivePort.sendPort, rawData]);

    final result = await receivePort.first;

    if (result is List<OrderModel>) {
      return result;
    } else {
      print('Error al procesar datos en isolate');
      return [];
    }
  }

  void _orderParsingIsolate(List<dynamic> message) {
    final SendPort sendPort = message[0];
    final List<Map<String, dynamic>> rawData = List<Map<String, dynamic>>.from(message[1]);

    try {
      final List<OrderModel> orders = rawData.map((map) => OrderModel.fromMap(map)).toList();
      sendPort.send(orders);
    } catch (e) {
      print('Error al convertir los datos en OrderModel: $e');
      sendPort.send([]);
    }
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    try {
      final userId = _getCurrentUserId();
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

  Future<void> _saveOrderToCache(OrderModel order) async {
    final db = await database;
    final orderMap = order.toMap();

    await db.insert(
      _tableName,
      orderMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _keepOnlyRecentOrders();
  }

  Future<void> _keepOnlyRecentOrders() async {
    final db = await database;
    final count = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    final int? total = count.first.values.first as int?;

    if (total != null && total > _maxCachedOrders) {
      final idsToDelete = await db.rawQuery('''
        SELECT orderId FROM $_tableName 
        ORDER BY orderDate ASC 
        LIMIT ${total - _maxCachedOrders}
      ''');

      final ids = idsToDelete.map((e) => e['orderId'] as String).toList();
      await db.delete(
        _tableName,
        where: 'orderId IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
    }
  }

  Future<List<OrderModel>> getOrdersFromCache() async {
    final db = await database;
    final List<Map<String, dynamic>> dbData = await db.query(
      _tableName,
      orderBy: 'orderDate DESC',
      limit: _maxCachedOrders,
    );

    if (dbData.isEmpty) {
      return [];
    }

    // Mantenemos el isolate solo para el cache
    return await _parseOrdersInIsolate(dbData);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final userId = _getCurrentUserId();

    if (userId == null) {
      print('Usuario no autenticado. Usando caché.');
      return await getOrdersFromCache();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(_maxCachedOrders)
          .get();

      // Procesamiento directo sin isolate
      final results = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      if (results.isEmpty) {
        return [];
      }

      // Actualizar cache
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete(_tableName);
        for (final order in results) {
          await txn.insert(
            _tableName,
            order.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return results;
    } catch (e) {
      print('Error al obtener pedidos: $e');
      return await getOrdersFromCache();
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final now = DateTime.now();
      final updateData = {
        'status': newStatus,
        'statusUpdatedAt': now.toIso8601String(),
      };

      if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = now.toIso8601String();
        updateData['cancelledBy'] = user?.uid ?? 'system';
      }

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc(orderId)
            .update(updateData);
      }

      // Update local cache
      final db = await database;
      final dbUpdateData = {
        'status': newStatus,
        'statusUpdatedAt': now.toIso8601String(),
      };

      if (newStatus == 'cancelled') {
        dbUpdateData['cancelledAt'] = now.toIso8601String();
        dbUpdateData['cancelledBy'] = user?.uid ?? 'system';
      }

      await db.update(
        _tableName,
        dbUpdateData,
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}