import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ViewModels/restaurant_detail_viewmodel.dart';
import 'home_page.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;
  final bool isFavoritePage;
  final RestaurantDetailViewModel viewModel = RestaurantDetailViewModel();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

  RestaurantDetailPage({
    super.key,
    required this.restaurant,
    this.isFavoritePage = false,
  });

  Future<bool> _checkInternetAndShowMessage(BuildContext context) async {
    final isConnected = await ConnectivityService().isConnected();
    if (!isConnected && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please try again when you have internet access.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return isConnected;
  }

  @override
  Widget build(BuildContext context) {
    final product = restaurant.products[0];
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: restaurant.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "\$${restaurant.products[0].originalPrice}",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: isFavoritePage
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "\$${restaurant.products[0].discountPrice}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isFavoritePage
                                          ? Colors.white
                                          : const Color(0xFF2A9D8F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Restaurant name (address)
                    Row(
                      children: [
                        const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.name,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      restaurant.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Button Row - Add to Cart + Directions
                    Row(
                      children: [
                        // Add to Cart Button (expanded to take available space)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A9D8F),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (await _checkInternetAndShowMessage(context)) {
                                _showOrderDialog(context);
                              }
                            },
                            child: const Text(
                              'Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Spacing between buttons
                        // Directions Button (icon only)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.directions, color: Colors.white),
                            padding: const EdgeInsets.all(16),
                            onPressed: () async {
                              if (await _checkInternetAndShowMessage(context)) {
                                await viewModel.logDirections(product.productId.toString());
                                final Uri directionsUri = Uri.parse(
                                    'https://www.google.com/maps/dir/?api=1&destination='
                                        '${restaurant.latitude},${restaurant.longitude}&travelmode=driving'
                                );

                                if (await canLaunchUrl(directionsUri)) {
                                  await launchUrl(directionsUri);
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(
                                          "Could not launch Google Maps")));
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Map
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                restaurant.latitude, restaurant.longitude),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(restaurant.name),
                              position: LatLng(restaurant.latitude,
                                  restaurant.longitude),
                              infoWindow: InfoWindow(
                                  title: restaurant.name),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    final product = restaurant.products[0];
    int selectedQuantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Select Quantity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${product.productName}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: selectedQuantity > 1
                            ? () {
                          setState(() {
                            selectedQuantity--;
                          });
                        }
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$selectedQuantity',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: selectedQuantity < product.amount
                            ? () {
                          setState(() {
                            selectedQuantity++;
                          });
                        }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max available: ${product.amount}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    // Show loading dialog
                    showDialog(
                      context: scaffoldMessengerKey.currentContext!,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF2A9D8F))),
                              const SizedBox(height: 20),
                              const Text(
                                'Processing your order...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    try {
                      final isConnected = await ConnectivityService().isConnected();
                      if (!isConnected) {
                        if (scaffoldMessengerKey.currentContext != null && scaffoldMessengerKey.currentContext!.mounted) {
                          Navigator.of(scaffoldMessengerKey.currentContext!, rootNavigator: true).pop();
                          ScaffoldMessenger.of(scaffoldMessengerKey.currentContext!).showSnackBar(
                            const SnackBar(
                              content: Text('No internet connection. Please try again when you have internet access.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }

                      final orderCode = await viewModel.orderItem(
                          product.productId, selectedQuantity);

                      Navigator.of(scaffoldMessengerKey.currentContext!,
                          rootNavigator: true).pop();

                      if (orderCode == "Error") {
                        _showErrorDialog(scaffoldMessengerKey.currentContext!);
                      } else {
                        await viewModel.sendOrderAnalitycs(product.productId, product.productName, selectedQuantity);
                        _showOrderConfirmationDialog(
                            scaffoldMessengerKey.currentContext!,
                            orderCode!
                        );
                      }
                    } catch (e) {
                      // Close loading dialog in case of error
                      if (scaffoldMessengerKey.currentContext != null && scaffoldMessengerKey.currentContext!.mounted) {
                        Navigator.of(scaffoldMessengerKey.currentContext!,
                            rootNavigator: true).pop();
                        _showErrorDialog(
                            scaffoldMessengerKey.currentContext!,
                            errorMessage: 'Error: ${e.toString()}'
                        );
                      }
                    }
                  },
                  child: const Text('Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, String orderCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Your order has been placed successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Code:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  orderCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Color(0xFF2A9D8F),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please save this code for reference',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(selectedIndex: 0),
                      settings: const RouteSettings(name: "HomePage")
                  ),
                );
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF2A9D8F))),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context,
      {String errorMessage = "An error occurred while processing your order"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF2A9D8F))),
            ),
          ],
        );
      },
    );
  }
}