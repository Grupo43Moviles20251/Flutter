import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            pinned: true,

          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con nombre y rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              restaurant.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Dirección
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        restaurant.address,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Descripción
                  Text(
                    restaurant.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),

                  // Mapa (placeholder)
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(restaurant.latitude, restaurant.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(restaurant.name),
                            position: LatLng(restaurant.latitude, restaurant.longitude),
                            infoWindow: InfoWindow(title: restaurant.name),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          // Puedes guardar el controlador si lo necesitas después
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Productos disponibles
                  Text(
                    "Surprise Bags Disponibles",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Lista de productos
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final product = restaurant.products[index];
                return _buildProductCard(product);
              },
              childCount: restaurant.products.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.green),
                SizedBox(width: 4),
                Text("Disponibles: ${product.amount}"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.originalPrice != product.discountPrice)
                      Text(
                        "\$${product.originalPrice}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      "\$${product.discountPrice}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Acción para agregar al carrito
                  },
                  child: Text("Agregar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}