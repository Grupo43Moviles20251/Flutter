import 'package:first_app/Models/restaurant_model.dart';
import 'package:first_app/Repositories/restaurant_repository.dart';
import 'package:first_app/ViewModels/search_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final int selectedIndex;

  SearchPage({this.selectedIndex = 1});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(  // Usamos el ViewModel para manejar la lógica
        builder: (context, viewModel, child) {
          return CustomScaffold(
            body: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      viewModel.searchRestaurants(query); // Buscar en tiempo real
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Filtros grandes, uno encima del otro
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FilterButton(
                        label: 'Cafés',
                        iconPath: 'assets/cafe.png', // Ruta al icono
                        onPressed: () {
                          viewModel.searchRestaurants(_searchController.text, type: 2);
                        },
                      ),
                      SizedBox(height: 10),  // Espacio entre botones
                      FilterButton(
                        label: 'Restaurants',
                        iconPath: 'assets/restaurant.png',  // Ruta al icono
                        onPressed: () {
                          viewModel.searchRestaurants(_searchController.text, type: 1);
                        },
                      ),
                      SizedBox(height: 10),
                      FilterButton(
                        label: 'SuperMarkets',
                        iconPath: 'assets/market.png',  // Ruta al icono
                        onPressed: () {
                          viewModel.searchRestaurants(_searchController.text, type: 3);
                        },
                      ),
                    ],
                  ),
                ),

                // Mostrar los restaurantes cuando se aplica el filtro o la búsqueda
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.restaurants.length,
                    itemBuilder: (context, index) {
                      Restaurant restaurant = viewModel.restaurants[index];
                      return _buildRestaurantCard(restaurant);
                    },
                  ),
                ),
              ],
            ),
            selectedIndex: selectedIndex, // Pasamos el índice seleccionado aquí
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(restaurant.imageUrl,
                height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Surprise bag", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text("${restaurant.rating}", style: TextStyle(fontSize: 14)),
                    Spacer(),
                    Text("\$${restaurant.products[0].originalPrice}",
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey)),
                    SizedBox(width: 5),
                    Text("\$${restaurant.products[0].discountPrice}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF38677A))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final String iconPath;  // Ruta al icono
  final VoidCallback onPressed;

  FilterButton({required this.label, required this.iconPath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2A9D8F), // Color de fondo
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,  // Centrado de los elementos
        crossAxisAlignment: CrossAxisAlignment.center,  // Alineación vertical
        children: [
          Image.asset(
            iconPath,
            width: 30,  // Tamaño del icono
            height: 30,  // Tamaño del icono
          ),
          SizedBox(width: 10),  // Espacio entre el icono y el texto
          Text(
            label,
            style: TextStyle(
              fontFamily: 'MontserratAlternates',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
