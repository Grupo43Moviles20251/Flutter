import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
            body: _buildMap(context, viewModel),
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
        zoom: 14,
      ),
      markers: viewModel.getMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
