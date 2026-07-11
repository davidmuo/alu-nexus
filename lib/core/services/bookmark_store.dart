import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide store of bookmarked opportunity IDs, persisted locally.
/// Works identically in demo and live mode.
class BookmarkStore extends ChangeNotifier {
  BookmarkStore._();
  static final BookmarkStore instance = BookmarkStore._();

  static const _prefsKey = 'bookmarked_opportunity_ids';

  Set<String> _ids = {};
  bool _loaded = false;

  Set<String> get ids => Set.unmodifiable(_ids);
  bool contains(String id) => _ids.contains(id);

  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _ids.toList());
  }
}
