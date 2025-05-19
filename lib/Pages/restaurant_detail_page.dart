import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ViewModels/restaurant_detail_viewmodel.dart';
import 'home_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final bool isFavoritePage;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurant,
    this.isFavoritePage = false,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final RestaurantDetailViewModel viewModel = RestaurantDetailViewModel();
  bool _isLoading = false;

  Future<bool> _checkInternetAndShowMessage() async {
    final isConnected = await ConnectivityService().isConnected();
    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please try again when you have internet access.'),
            duration: Duration(seconds: 3),
          ));
      }
          return isConnected;
      }

  Future<void> _showOrderDialog() async {
    final product = widget.restaurant.products[0];

    // Verificar si hay productos disponibles
    if (product.amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This product is currently out of stock.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    int selectedQuantity = 1;

    final result = await showDialog<bool>(
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
                            ? () => setState(() => selectedQuantity--)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text('$selectedQuantity', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: selectedQuantity < product.amount
                            ? () => setState(() => selectedQuantity++)
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
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Order'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await _processOrder(product, selectedQuantity);
    }
  }


  Future<void> _processOrder(Product product, int quantity) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final isConnected = await ConnectivityService().isConnected();
      if (!isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No internet connection. Please try again when you have internet access.'),
                duration: Duration(seconds: 3),
              ));
              }
              return;
              }

              final orderCode = await viewModel.orderItem(product.productId, quantity);

          if (!mounted) return;

          if (orderCode == "Error") {
            _showErrorDialog();
          } else {
            await viewModel.sendOrderAnalitycs(product.productId, product.productName, quantity);
            await viewModel.logDetailEvent(product.productId.toString(), "order");
            _showOrderConfirmationDialog(orderCode!);
          }
        } catch (e) {
      if (mounted) {
        _showErrorDialog(errorMessage: 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.restaurant.products[0];
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: widget.restaurant.imageUrl,
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
                                  product.productName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "\$${product.originalPrice}",
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: widget.isFavoritePage
                                            ? Colors.white70
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "\$${product.discountPrice}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: widget.isFavoritePage
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
                                  widget.restaurant.rating.toString(),
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
                            widget.restaurant.name,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        widget.restaurant.description,
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
                                backgroundColor: product.amount > 0
                                    ? const Color(0xFF2A9D8F)
                                    : Colors.grey, // Cambia el color si no hay stock
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading || product.amount <= 0
                                  ? null
                                  : () async {
                                if (await _checkInternetAndShowMessage()) {
                                  await _showOrderDialog();
                                }
                              },
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : product.amount > 0
                                  ? const Text(
                                'Order',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Out of Stock',
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
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                if (await _checkInternetAndShowMessage()) {
                                  await viewModel.logDetailEvent(product.productId.toString(), "directions");
                                  final Uri directionsUri = Uri.parse(
                                      'https://www.google.com/maps/dir/?api=1&destination='
                                          '${widget.restaurant.latitude},${widget.restaurant.longitude}&travelmode=driving'
                                  );

                                  if (await canLaunchUrl(directionsUri)) {
                                    await launchUrl(directionsUri);
                                  } else if (mounted) {
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
                                  widget.restaurant.latitude, widget.restaurant.longitude),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(widget.restaurant.name),
                                position: LatLng(widget.restaurant.latitude,
                                    widget.restaurant.longitude),
                                infoWindow: InfoWindow(
                                    title: widget.restaurant.name),
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog(String orderCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _showErrorDialog({String errorMessage = "An error occurred while processing your order"}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }
}