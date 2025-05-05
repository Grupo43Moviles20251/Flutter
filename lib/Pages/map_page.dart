import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  late MapViewModel _viewModel;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late Connectivity _connectivity;
  bool _initialLoadComplete = false;
  bool _shouldCenterOnUser = true;

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel();
    _connectivity = Connectivity();
    _initConnectivity();

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _loadData();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
      return;
    }

    if (!mounted) return;
    setState(() {
      _connectionStatus = result.isNotEmpty ? result.first : ConnectivityResult.none;
    });
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final newStatus = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final wasOffline = _connectionStatus == ConnectivityResult.none;
    final isNowOnline = newStatus != ConnectivityResult.none;

    setState(() {
      _connectionStatus = newStatus;
    });

    if (wasOffline && isNowOnline) {
      // Cuando volvemos a tener conexión
      setState(() {
        _shouldCenterOnUser = true; // Indicar que debemos centrar en el usuario
      });
      await _loadData();
    }
  }
  Future<void> _loadData() async {
    try {
      await _viewModel.initialize();
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading map data: $e');
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  bool get _isOnline => _connectionStatus != ConnectivityResult.none;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _viewModel,
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            body: Stack(
              children: [
                if (!_isOnline) _buildOfflineMessage(),
                if (_isOnline && _initialLoadComplete) _buildMap(context, viewModel),
                if (_isOnline && !_initialLoadComplete) _buildLoadingIndicator(),
                if (viewModel.selectedRestaurant != null && _isOnline && _initialLoadComplete)
                  _buildRestaurantInfo(context, viewModel.selectedRestaurant!),
              ],
            ),
            selectedIndex: widget.selectedIndex,
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
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
              onPressed: _initConnectivity,
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapViewModel viewModel) {
    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.error!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
        _centerMapOnUser(viewModel.userLocation);
      },
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

  void _centerMapOnUser(LatLng? userLocation) {
    if (userLocation != null && _shouldCenterOnUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(userLocation),
        );
        setState(() {
          _shouldCenterOnUser = false; // Ya hemos centrado el mapa
        });
      });
    }
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_connectionStatus != ConnectivityResult.none && _initialLoadComplete) {
      _centerMapOnUser(_viewModel.userLocation);
    }
  }

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
    double averagePrice = restaurant.products.isNotEmpty
        ? restaurant.products.map((p) => p.discountPrice).reduce((a, b) => a + b) /
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                restaurant.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
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
                  "Average: \$${averagePrice.toStringAsFixed(2)}",
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
              children: [
                ElevatedButton(
                  onPressed: () {
                    _navigateToRestaurant(
                        restaurant.latitude, restaurant.longitude);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38677A),
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