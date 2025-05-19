class OrderModel {
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String orderDate;
  final String status;

  OrderModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.orderDate,
    required this.status,
  });


  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'orderDate': orderDate,
      'status': status,
    };
  }

  // Create from Map (from Firebase)
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      orderDate: map['orderDate'],
      status: map['status'],
    );
  }
}