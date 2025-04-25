import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this import

import '../Models/restaurant_model.dart';
import '../ViewModels/map_viewmodel.dart';

class MapPage extends StatefulWidget {
  final int selectedIndex;
  const MapPage({super.key, this.selectedIndex = 3});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  bool _isOnline = true;
  late MapViewModel _viewModel = MapViewModel();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _viewModel.reset();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await ConnectivityService().isConnected();
    if (mounted) {
      setState(() {
        _isOnline = connectivityResult;
      });
    }

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        _viewModel = MapViewModel()..initialize();
        return _viewModel;
      },
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            body: Stack(
              children: [
                if (!_isOnline) _buildOfflineMessage(),
                if (_isOnline) _buildMap(context, viewModel),
                if (viewModel.selectedRestaurant != null && _isOnline)
                  _buildRestaurantInfo(context, viewModel.selectedRestaurant!),
              ],
            ),
            selectedIndex: widget.selectedIndex,
          );
        },
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'The map requires an internet connection to function properly.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkConnectivity,
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }

    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: CameraPosition(
        target: viewModel.userLocation ?? const LatLng(4.710989, -74.072092),
        zoom: 16,
      ),
      markers: viewModel.getMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onTap: (_) => viewModel.clearSelection(),
    );
  }

// ... [keep all your existing methods below unchanged]


  Future<void> _navigateToRestaurant(double lat, double lng) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo abrir Google Maps: $url';
    }
  }


  Widget _buildRestaurantInfo(BuildContext context, Restaurant restaurant) {
    // Calcular el precio promedio de los productos
    double averagePrice = restaurant.products.isNotEmpty
        ? restaurant.products.map((p) => p.discountPrice).reduce((a, b) =>
    a + b) /
        restaurant.products.length
        : 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del restaurante
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                restaurant.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            // Nombre del restaurante
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailPage(restaurant: restaurant),
                  ),
                );
              },
              child: Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Dirección
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  restaurant.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Descripción
            Text(
              restaurant.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            // Rating y precio promedio
            Row(
              children: [
                // Rating
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  restaurant.rating.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),

                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  "Average Price: \$${averagePrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // Distribuye el espacio uniformemente
              children: [
                // Botón para obtener direcciones
                ElevatedButton(
                  onPressed: () {
                    _navigateToRestaurant(
                        restaurant.latitude, restaurant.longitude);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF38677A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Get Directions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}