import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/favorites_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:first_app/Pages/restaurant_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  final int selectedIndex;
  FavoritesPage({this.selectedIndex = 1});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final _viewModel = FavoritesViewModel();
        _viewModel.fetchFavorites(); // Initial load
        return _viewModel;
      },
      child: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          return CustomScaffold(
            selectedIndex: 1, // índice de favoritos
            body: RefreshIndicator(
              onRefresh: () => vm.fetchFavorites(),
              child: vm.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : vm.favorites.isEmpty
                  ? Center(
                child: Text(
                  "¡Ups! No tienes ningún favorito aún.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.favorites.length,
                      itemBuilder: (ctx, i) {
                        final r = vm.favorites[i];
                        return RestaurantCard(
                          restaurant: r,
                          isFavoritePage: true,
                          isFavorite: true,
                          onFavoriteToggle: () {
                            vm.toggleFavorite(r);
                          },
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
                  if (vm.hasMoreItems)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => vm.loadMoreFavorites(),
                        child: Text(
                          'Load More',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A9D8F),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}