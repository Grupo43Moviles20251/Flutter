import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/ViewModels/search_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final int selectedIndex;
  SearchPage({this.selectedIndex = 1});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel()..loadAllRestaurants(),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            selectedIndex: selectedIndex,
            body: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: viewModel.searchRestaurants,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Filtros (uno sobre otro)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      FilterButton(
                        label: 'Cafés',
                        iconPath: 'assets/cafe.png',
                        onPressed: () => viewModel.searchRestaurants(
                          _searchController.text,
                          type: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      FilterButton(
                        label: 'Restaurants',
                        iconPath: 'assets/restaurant.png',
                        onPressed: () => viewModel.searchRestaurants(
                          _searchController.text,
                          type: 1,
                        ),
                      ),
                      SizedBox(height: 10),
                      FilterButton(
                        label: 'SuperMarkets',
                        iconPath: 'assets/market.png',
                        onPressed: () => viewModel.searchRestaurants(
                          _searchController.text,
                          type: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de resultados
                if (viewModel.isLoading)
                  Expanded(child: Center(child: CircularProgressIndicator()))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.restaurants.length,
                      itemBuilder: (context, index) {
                        final r = viewModel.restaurants[index];
                        return RestaurantCard(
                          restaurant: r,
                          isFavoritePage: false,
                          isFavorite: viewModel.isFavorite(r),
                          onFavoriteToggle: () => viewModel.toggleFavorite(r),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailPage(restaurant: r),
                                settings: RouteSettings(name: "RestaurantDetail"),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class FilterButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onPressed;

  FilterButton({
    required this.label,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2A9D8F),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 30, height: 30),
          SizedBox(width: 10),
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
