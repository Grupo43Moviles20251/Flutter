import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/favorites_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'dart:async';

class FavoritesPage extends StatefulWidget {
  final int selectedIndex;
  FavoritesPage({this.selectedIndex = 1});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late FavoritesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _initConnectivityListener() {
    // Check initial connectivity status
    ConnectivityService().isConnected().then((connected) {
      if (mounted) {
        setState(() {
          isOnline = connected;
        });
      }
    });

    // Listen for connectivity changes
    _connectivitySubscription = ConnectivityService().connectivityStream.listen((results) async {
      // When connectivity changes, verify if we actually have internet access
      final connected = await ConnectivityService().isConnected();
      if (mounted) {
        setState(() {
          isOnline = connected;
        });

        // Show a snackbar when connectivity changes
        if (connected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Internet connection restored. Reloading favorites...'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
          // Reload data when connection is restored
          _viewModel.fetchFavorites();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No internet connection'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        _viewModel = FavoritesViewModel();
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
                  isOnline
                      ? "¡Ups! No tienes ningún favorito aún.\nApresúrate, hay muchos platos que te encantarán 😋"
                      : "No internet connection. Favorites cannot be loaded.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: vm.favorites.length,
                itemBuilder: (ctx, i) {
                  final r = vm.favorites[i];
                  return RestaurantCard(
                    restaurant: r,
                    isFavoritePage: true,
                    isFavorite: true,
                    onFavoriteToggle: () {
                      if (!isOnline) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No internet connection. Cannot update favorites.'),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      vm.toggleFavorite(r);
                    },
                    onTap: () {
                      if (!isOnline) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No internet connection. Restaurant details unavailable.'),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
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
          );
        },
      ),
    );
  }
}