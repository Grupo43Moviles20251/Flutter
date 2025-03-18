import 'package:first_app/Pages/home_viewmodel.dart';
import 'package:first_app/Models/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadRestaurants(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Image.asset('assets/logo.png', height: 40),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.black, size: 30),
                  onPressed: () {
                    // Navegar a la página de usuario
                  },
                ),
              ],
            ),
            body: viewModel.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: viewModel.restaurants.length,
              itemBuilder: (context, index) {
                Restaurant restaurant = viewModel.restaurants[index];
                return _buildRestaurantCard(restaurant);
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Color(0xFF38677A),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Restaurants"),
                BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
              ],
            ),
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
                Text(restaurant.name, style: TextStyle(color: Color(0xFF38677A), fontFamily: 'MontserratAlternates', fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Surprise bag", style: TextStyle(color: Color(0xFF38677A), fontFamily: 'MontserratAlternates')),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text("${restaurant.rating}", style: TextStyle(fontFamily: 'MontserratAlternates',fontSize: 14)),
                    Spacer(),
                    Text("\$${restaurant.products[0].originalPrice}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    SizedBox(width: 5),
                    Text("\$${restaurant.products[0].discountPrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF38677A), fontFamily: 'MontserratAlternates')),
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
