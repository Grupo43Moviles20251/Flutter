import 'package:first_app/Pages/restaurant_detail_page.dart';
import 'package:first_app/ViewModels/home_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  HomePage({this.selectedIndex = 0, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel()..loadRestaurants();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Llegamos al final de la lista
      if (_viewModel.hasMoreItems && !_viewModel.isLoadingMore) {
        _viewModel.loadRestaurants(loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            selectedIndex: widget.selectedIndex,
            body: RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.restaurants.isEmpty) {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.restaurants.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                viewModel.isOffline ? Icons.wifi_off : Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                viewModel.isOffline
                    ? "No internet connection. Pull down to refresh."
                    : "No products found.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (viewModel.isOffline)
                TextButton(
                  onPressed: _refreshData,
                  child: Text('Try again'),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.restaurants.length + (viewModel.hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= viewModel.restaurants.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: viewModel.isLoadingMore
                    ? CircularProgressIndicator()
                    : Text('No more items'),
              ),
            );
          }

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

  Future<void> _refreshData() async {
    await _viewModel.loadRestaurants();
  }
}