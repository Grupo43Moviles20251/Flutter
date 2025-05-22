import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/ViewModels/home_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  const HomePage({this.selectedIndex = 0, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasInternet = true;
  late Stream<List<ConnectivityResult>> _connectivityStream;
  bool _isProviderInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProviderInitialized) {
      _isProviderInitialized = true;
      _initializeScrollListener();
    }
  }

  void _initializeScrollListener() {
    _scrollController.addListener(_scrollListener);
  }

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      if (viewModel.hasMoreItems && !viewModel.isLoadingMore && _hasInternet) {
        viewModel.loadMoreItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return CustomScaffold(
      selectedIndex: widget.selectedIndex,
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
                  ? () => viewModel.loadRestaurants()
                  : () async {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _buildContent(viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.restaurants.isEmpty) {
      return Expanded(
        child: Center(
          child: _hasInternet
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No internet connection'),
              const Text('Please connect to the internet to view restaurants'),
            ],
          ),
        ),
      );
    }

    if (!_hasInternet && viewModel.restaurants.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No internet connection'),
              const Text('Please connect to the internet to view restaurants'),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: viewModel.restaurants.length,
              itemBuilder: (context, index) {
                final r = viewModel.restaurants[index];
                return RestaurantCard(
                  restaurant: r,
                  isFavoritePage: false,
                  isFavorite: viewModel.isFavorite(r),
                  onFavoriteToggle: () {
                    if (_hasInternet) {
                      viewModel.toggleFavorite(r);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
                        settings: const RouteSettings(name: "RestaurantDetail"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (viewModel.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (viewModel.hasMoreItems && !viewModel.isLoadingMore && _hasInternet)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => viewModel.loadMoreItems(),
                child: const Text('Load More'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomePageWrapper extends StatelessWidget {
  final int selectedIndex;
  const HomePageWrapper({this.selectedIndex = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: HomePage(selectedIndex: selectedIndex),
    );
  }
}