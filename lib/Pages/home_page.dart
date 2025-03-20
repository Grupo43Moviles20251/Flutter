import 'package:flutter/material.dart';
import 'package:first_app/ViewModels/home_viewmodel.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:provider/provider.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';

class HomePage extends StatelessWidget {
  final int selectedIndex ;
  HomePage({this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadRestaurants(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return CustomScaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título antes de las tarjetas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Restaurants for you",  // Título antes de las tarjetas
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MontserratAlternates',
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                ),

                // Mostrar las tarjetas de los restaurantes
                viewModel.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
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
            selectedIndex: selectedIndex,  // Asegúrate de pasar este índice
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
            child: Image.network(restaurant.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Surprise bag", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text("${restaurant.rating}", style: TextStyle(fontSize: 14)),
                    Spacer(),
                    Text("\$${restaurant.products[0].originalPrice}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    SizedBox(width: 5),
                    Text("\$${restaurant.products[0].discountPrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2A9D8F))),
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
