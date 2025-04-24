import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/ViewModels/home_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatelessWidget {
  final int selectedIndex;
  HomePage({this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadRestaurants(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            selectedIndex: selectedIndex,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Products for you",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MontserratAlternates',
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                ),
                _buildContent(viewModel)
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildContent(HomeViewModel viewModel){
    // Loader o lista
    if (viewModel.isLoading) {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
      if(viewModel.restaurants.isEmpty){
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                viewModel.isOffline
                    ? "No products available. Please connect to the internet."
                    : "No products found.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),


            ],
          ),
        ),
      );

    }
     return Expanded(
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
      );
  }
}
