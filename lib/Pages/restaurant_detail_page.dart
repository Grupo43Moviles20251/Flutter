import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;
  final bool isFavoritePage;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    this.isFavoritePage = false,
  });

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
                  // Header with product name, price and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.products[0].productName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "\$${restaurant.products[0].originalPrice}",
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: isFavoritePage ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "\$${restaurant.products[0].discountPrice}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isFavoritePage
                                        ? Colors.white
                                        : Color(0xFF2A9D8F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                  SizedBox(height: 16),

                  // Restaurant name (address)
                  Row(
                    children: [
                      Icon(Icons.restaurant, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        restaurant.name,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    restaurant.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),

                  // Button Row - Add to Cart + Directions
                  Row(
                    children: [
                      // Add to Cart Button (expanded to take available space)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2A9D8F),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${restaurant.products[0].productName} added to cart'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // Spacing between buttons
                      // Directions Button (icon only)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.directions, color: Colors.white),
                          padding: EdgeInsets.all(16),
                          onPressed: () async {
                            final Uri directionsUri = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination='
                                    '${restaurant.latitude},${restaurant.longitude}&travelmode=driving'
                            );

                            if (await canLaunchUrl(directionsUri)) {
                              await launchUrl(directionsUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Could not launch Google Maps")));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Map
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
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                        },
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        myLocationEnabled: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}