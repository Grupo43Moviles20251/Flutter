import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/recommended_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/top_restaurant_card.dart';
import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RecommendedPage extends StatefulWidget {
  @override
  _RecommendedPageState createState() => _RecommendedPageState();
}

class _RecommendedPageState extends State<RecommendedPage> {
  bool _hasInternet = true;
  late RecommendedViewModel _viewModel;
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _viewModel = RecommendedViewModel();
    _checkInternetConnection().then((_) {
      _hasInternet
          ? _viewModel.loadRecommended()
          : _viewModel.loadTop3FromCache();
    });

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
    final connected = !result.contains(ConnectivityResult.none);
    if (_hasInternet != connected) {
      setState(() {
        _hasInternet = connected;
      });

      // Si cambia el estado, recargamos desde red o caché
      connected
          ? _viewModel.loadRecommended()
          : _viewModel.loadTop3FromCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<RecommendedViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            selectedIndex: 1,
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
                        ? () => vm.loadRecommended()
                        : () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No internet connection. Cannot refresh.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return Future.value();
                          },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TÍTULO
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Top Products",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'MontserratAlternates',
                              color: Color(0xFF2A9D8F),
                            ),
                          ),
                        ),

                        // CONTENIDO
                        if (vm.isLoading && vm.restaurants.isEmpty)
                          Expanded(child: Center(child: CircularProgressIndicator()))
                        else if (vm.restaurants.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                _hasInternet
                                    ? "No recommendations available at the moment."
                                    : "No cached recommendations found.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: vm.restaurants.length,
                              itemBuilder: (context, index) {
                                final r = vm.restaurants[index];
                                return TopRestaurantCard(
                                  restaurant: r,
                                  position: index + 1,
                                  isFavorite: vm.isFavorite(r),
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
                      ],
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
