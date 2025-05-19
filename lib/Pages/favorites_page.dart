import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/favorites_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FavoritesPage extends StatefulWidget {
  final int selectedIndex;
  FavoritesPage({this.selectedIndex = 1});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _hasInternet = true;
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _hasInternet = !result.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final _viewModel = FavoritesViewModel();
        if (_hasInternet) {
          _viewModel.fetchFavorites(); // Initial load only if online
        }
        return _viewModel;
      },
      child: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          return CustomScaffold(
            selectedIndex: 1, // índice de favoritos
            body: Column(
              children: [
                if (!_hasInternet)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'No internet connection',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _hasInternet
                        ? () => vm.fetchFavorites()
                        : () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No internet connection. Cannot refresh favorites.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return Future.value();
                    },
                    child: _buildContent(vm),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(FavoritesViewModel vm) {
    if (vm.isLoading && vm.favorites.isEmpty) {
      return Center(
        child: _hasInternet
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No internet connection'),
            Text('Please connect to the internet to view favorites'),
          ],
        ),
      );
    }

    if (!_hasInternet && vm.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No internet connection'),
            Text('Please connect to the internet to view favorites'),
          ],
        ),
      );
    }

    if (vm.favorites.isEmpty) {
      return Center(
        child: Text(
          "¡Ups! No tienes ningún favorito aún.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Column(
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
                  if (_hasInternet) {
                    vm.toggleFavorite(r);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No internet connection. Cannot toggle favorite.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
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
        if (vm.hasMoreItems && _hasInternet)
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
    );
  }
}