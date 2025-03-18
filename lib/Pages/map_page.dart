import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  final int selectedIndex;
  MapPage({this.selectedIndex = 3});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Text(
          "Mapa de la zona",  // Aquí puedes agregar tu mapa más tarde
          style: TextStyle(fontSize: 20),
        ),
      ),
      selectedIndex: selectedIndex,
    );
  }
}
