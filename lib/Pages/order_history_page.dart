import 'package:flutter/material.dart';
import 'package:first_app/Models/order_model.dart';
import 'package:first_app/ViewModels/order_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OrderHistoryPage extends StatefulWidget {
  final OrderViewModel orderViewModel;

  const OrderHistoryPage({Key? key, required this.orderViewModel}) : super(key: key);

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<OrderModel>> _ordersFuture;
  bool _isLoading = false;
  bool _hasInternet = true;
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrdersWithConnectivityCheck();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        setState(() {
          _hasInternet = false;
        });
      } else {
        setState(() {
          _hasInternet = true;
        });
      }
    });
  }

  Future<List<OrderModel>> _fetchOrdersWithConnectivityCheck() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        _hasInternet = false;
      });
      return [];
    }

    setState(() {
      _hasInternet = true;
    });
    return widget.orderViewModel.getOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final orders = await _fetchOrdersWithConnectivityCheck();
      setState(() {
        _ordersFuture = Future.value(orders);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _hasInternet ? _refreshOrders : null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasInternet)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<OrderModel>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (!_hasInternet && (snapshot.data == null || snapshot.data!.isEmpty)) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No internet connection'),
                        Text('Connect to view your orders'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allOrders = snapshot.data ?? [];
                // Take only the last 10 orders
                final recentOrders = allOrders.take(10).toList();

                if (recentOrders.isEmpty) {
                  return const Center(
                    child: Text('No recent orders'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _hasInternet ? _refreshOrders : () async {},
                  child: ListView.builder(
                    itemCount: recentOrders.length,
                    itemBuilder: (context, index) {
                      final order = recentOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Quantity: ${order.quantity}'),
            const SizedBox(height: 8),
            Text('Total: \$${(order.price * order.quantity).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Date: ${order.orderDate}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${order.orderId}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (order.status == 'pending' && _hasInternet)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancelOrder(order.orderId),
                  child: const Text(
                    'CANCEL ORDER',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    if (!_hasInternet) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await widget.orderViewModel.updateOrderStatus(orderId, 'cancelled');
        await _refreshOrders();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}