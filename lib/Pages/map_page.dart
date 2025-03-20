import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final int selectedIndex;
  MapPage({this.selectedIndex = 3});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
    ),
      ),

    ), selectedIndex: selectedIndex
    );
  }
}
