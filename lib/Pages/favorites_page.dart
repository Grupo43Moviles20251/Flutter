import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/favorites_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:first_app/Pages/restaurant_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  final int selectedIndex;
  FavoritesPage({this.selectedIndex = 1}); // Cambia el índice por defecto a 1
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesViewModel(),
      child: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          return CustomScaffold(
            selectedIndex: 1, // índice de favoritos
            body: vm.isLoading
              ? Center(child: CircularProgressIndicator())
              : vm.favorites.isEmpty
                ? Center(child: Text(
                    "¡Ups! No tienes ningún favorito aún.\nApresúrate, hay muchos platos que te encantarán 😋",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ))
                : ListView.builder(
                    itemCount: vm.favorites.length,
                    itemBuilder: (ctx, i) {
                      final r = vm.favorites[i];
                      return RestaurantCard(
                        restaurant: r,
                        isFavoritePage:  true ,
                        isFavorite: true,
                        onFavoriteToggle: () => vm.toggleFavorite(r),
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
        },
      ),
    );
  }
}
