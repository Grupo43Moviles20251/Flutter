import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const _key = 'favorite_restaurant_names';

  Future<SharedPreferences> get _prefs async =>
    await SharedPreferences.getInstance();

  Future<Set<String>> getFavoriteNames() async {
    final p = await _prefs;
    return p.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<void> addFavorite(String restaurantName) async {
    final p = await _prefs;
    final names = await getFavoriteNames();
    names.add(restaurantName);
    await p.setStringList(_key, names.toList());
  }

  Future<void> removeFavorite(String restaurantName) async {
    final p = await _prefs;
    final names = await getFavoriteNames();
    names.remove(restaurantName);
    await p.setStringList(_key, names.toList());
  }

  Future<bool> isFavorite(String restaurantName) async {
    final names = await getFavoriteNames();
    return names.contains(restaurantName);
  }
}
