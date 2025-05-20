class OrderModel {
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String status;
  final String orderDate;
  final DateTime? statusUpdatedAt;
  final String? cancelledAt;
  final String? cancelledBy;


  OrderModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.status,
    required this.orderDate,
    this.statusUpdatedAt,
    this.cancelledAt,
    this.cancelledBy
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      status: map['status'],
      orderDate: map['orderDate'],
      statusUpdatedAt: map['statusUpdatedAt'] != null
          ? DateTime.parse(map['statusUpdatedAt'])
          : null,
      cancelledAt: map['cancelledAt'],
      cancelledBy: map['cancelledBy']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'status': status,
      'orderDate': orderDate,
      'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
      'cancelledAt': cancelledAt,
      'cancelledBy': cancelledBy,
    };
  }
}