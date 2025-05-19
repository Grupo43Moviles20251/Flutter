import 'dart:isolate';
import 'dart:async';
import 'dart:convert';
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

// Clase para pasar datos al isolate
class _IsolateData {
  final SendPort sendPort;
  final dynamic data;

  _IsolateData(this.sendPort, this.data);
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
            status TEXT
          )
        ''');
      },
    );
  }


  static void _parseOrdersInIsolate(_IsolateData isolateData) {
    try {
      if (isolateData.data is String) {

        final List<dynamic> jsonList = jsonDecode(isolateData.data);
        final orders = jsonList.map((json) => OrderModel.fromMap(json)).toList();
        isolateData.sendPort.send(orders);
      } else if (isolateData.data is List<Map<String, dynamic>>) {
        final orders = (isolateData.data as List<Map<String, dynamic>>)
            .map((map) => OrderModel.fromMap(map))
            .toList();
        isolateData.sendPort.send(orders);
      }
    } catch (e) {
      isolateData.sendPort.send([]);
    }
  }

  Future<List<OrderModel>> _processInIsolate(dynamic data) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _parseOrdersInIsolate,
      _IsolateData(receivePort.sendPort, data),
    );

    // Esperar el resultado del isolate
    final result = await receivePort.first;
    return result as List<OrderModel>;
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
    await db.insert(
      _tableName,
      order.toMap(),
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

    return await _processInIsolate(dbData);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final userId = _getCurrentUserId();

    if (userId == null) {
      return await getOrdersFromCache();
    }

    // Crear puerto de comunicación
    final receivePort = ReceivePort();

    try {

      await Isolate.spawn(
        _fetchFirebaseOrdersInIsolate,
        _FirebaseIsolateData(
            receivePort.sendPort,
            userId,
            _maxCachedOrders
        ),
      );

      // Esperar los resultados del isolate
      final results = await receivePort.first as _FirebaseIsolateResult;

      if (results.error != null) {
        print('Error en isolate: ${results.error}');
        return await getOrdersFromCache();
      }

      // Guardar en caché
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete(_tableName);
        for (final order in results.orders) {
          await txn.insert(_tableName, order.toMap());
        }
      });

      return results.orders;
    } catch (e) {
      print('Error en comunicación con isolate: $e');
      return await getOrdersFromCache();
    } finally {
      receivePort.close();
    }
  }



  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
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


      final db = await database;
      await db.update(
        _tableName,
        {'status': newStatus},
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
class _FirebaseIsolateData {
  final SendPort sendPort;
  final String userId;
  final int limit;

  _FirebaseIsolateData(this.sendPort, this.userId, this.limit);
}

// Estructura para recibir resultados del isolate
class _FirebaseIsolateResult {
  final List<OrderModel> orders;
  final String? error;

  _FirebaseIsolateResult(this.orders, this.error);
}

// Función que se ejecuta en el isolate
void _fetchFirebaseOrdersInIsolate(_FirebaseIsolateData data) async {
try {
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(data.userId)
    .collection('orders')
    .orderBy('orderDate', descending: true)
    .limit(data.limit)
    .get();

final orders = snapshot.docs
    .map((doc) => OrderModel.fromMap(doc.data()))
    .toList();

data.sendPort.send(_FirebaseIsolateResult(orders, null));
} catch (e) {
data.sendPort.send(_FirebaseIsolateResult([], e.toString()));
}
}