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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      if (viewModel.hasMoreItems && !viewModel.isLoadingMore) {
        viewModel.loadMoreItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return CustomScaffold(
            selectedIndex: widget.selectedIndex,
            body: RefreshIndicator(
              onRefresh: () => viewModel.loadRestaurants(),
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
          if (viewModel.isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (viewModel.hasMoreItems && !viewModel.isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => viewModel.loadMoreItems(),
                child: Text('Load More'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}