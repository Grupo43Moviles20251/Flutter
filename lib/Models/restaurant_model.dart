class Product {
  final int productId;
  final String productName;
  final int amount;
  final bool available;
  final double discountPrice;
  final double originalPrice;

  Product({
    required this.productId,
    required this.productName,
    required this.amount,
    required this.available,
    required this.discountPrice,
    required this.originalPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productName: json['productName'],
      amount: json['amount'],
      available: json['available'],
      discountPrice: json['discountPrice'],
      originalPrice: json['originalPrice'],
    );
  }
}

class Restaurant {
  final String name;
  final String imageUrl;
  final String description;
  final double latitude;  // Latitud
  final double longitude; // Longitud
  final String address;
  final List<Product> products;
  final double rating;
  final int type;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.products,
    required this.rating,
    required this.type,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List? ?? [];  // Si 'products' es null, usamos una lista vacía
    List<Product> productObjects = productList.map((e) => Product.fromJson(e)).toList();

    return Restaurant(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      latitude: json['latitude'],  // Ahora usamos 'latitude'
      longitude: json['longitude'],  // Y 'longitude'
      address: json['address'],
      products: productObjects,
      rating: json['rating'],
      type: json['type'],
    );
  }
}
