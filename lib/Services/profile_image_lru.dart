import 'dart:collection';
import 'dart:ui' as ui;

class ProfileImageCache {
  static final ProfileImageCache _instance = ProfileImageCache._internal();
  final int maxSize = 3;
  final LinkedHashMap<String, ui.Image> _cache = LinkedHashMap();

  factory ProfileImageCache() {
    return _instance;
  }

  ProfileImageCache._internal();

  ui.Image? get(String key) {
    if (_cache.containsKey(key)) {
      final image = _cache.remove(key);
      _cache[key] = image!;
      return image;
    }
    return null;
  }

  void put(String key, ui.Image image) {
    if (_cache.length >= maxSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = image;
  }

  void clear() {
    _cache.clear();
  }
}