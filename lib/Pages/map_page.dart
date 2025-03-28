import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel()..initialize(),
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            body: Stack(
              children: [
                _buildMap(context, viewModel),
                if (viewModel.selectedRestaurant != null)
                  _buildRestaurantInfo(context, viewModel.selectedRestaurant!),
              ],
            ),
            selectedIndex: widget.selectedIndex,
          );
        },
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
      onTap: (_) {

        viewModel.clearSelection();
      },
    );
  }

  Future<void> _navigateToRestaurant(double lat, double lng) async {
    final Uri url = Uri.parse( 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo abrir Google Maps: $url';
    }
  }


  Widget _buildRestaurantInfo(BuildContext context, Restaurant restaurant) {
    // Calcular el precio promedio de los productos
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
              color: Colors.black.withOpacity(0.1),
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
            Text(
              restaurant.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                // Precio promedio
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  "Precio promedio: \$${averagePrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón para obtener direcciones
            ElevatedButton(
              onPressed: () {
                _navigateToRestaurant(restaurant.latitude, restaurant.longitude);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF38677A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Cómo llegar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
