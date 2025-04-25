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
      create: (_) => SearchViewModel()..loadAllRestaurants(context),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            selectedIndex: selectedIndex,
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(
                    builder: (textFieldContext) {
                      return TextField(
                        controller: _searchController,
                        onChanged: (query) => viewModel.searchRestaurants(textFieldContext, query),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                ),

                // Filters
                if (!viewModel.isOffline) // Only show filters when online
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        FilterButton(
                          label: 'Cafés',
                          iconPath: 'assets/cafe.png',
                          onPressed: () => viewModel.searchRestaurants(
                            context,
                            _searchController.text,
                            type: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilterButton(
                          label: 'Restaurants',
                          iconPath: 'assets/restaurant.png',
                          onPressed: () => viewModel.searchRestaurants(
                            context,
                            _searchController.text,
                            type: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilterButton(
                          label: 'SuperMarkets',
                          iconPath: 'assets/market.png',
                          onPressed: () => viewModel.searchRestaurants(
                            context,
                            _searchController.text,
                            type: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Results or status
                if (viewModel.isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (viewModel.isOffline)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No Internet Connection',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Please check your connection and try again'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.loadAllRestaurants(context),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (viewModel.restaurants.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No restaurants found'),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.loadAllRestaurants(context),
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
                                    settings: const RouteSettings(name: "RestaurantDetail"),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
