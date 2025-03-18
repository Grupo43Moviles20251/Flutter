import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final int selectedIndex;
  FavoritesPage({this.selectedIndex = 1});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Text(
          "Aquí aparecerán tus restaurantes favoritos",  // Puedes agregar una lista de favoritos aquí
          style: TextStyle(fontSize: 20),
        ),
      ),
      selectedIndex: selectedIndex,  // Pasamos el índice seleccionado al CustomScaffold
    );
  }
}
