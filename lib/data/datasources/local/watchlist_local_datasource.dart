import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local datasource backing the mock watchlist.
///
/// Stores only movie IDs. When a real backend is available, this datasource
/// can be replaced with one that syncs the watchlist against the server while
/// keeping the same repository interface.
class WatchlistLocalDatasource {
  static const _watchlistKey = 'cinefy_watchlist';

  Future<Set<String>> _readIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_watchlistKey);
    return raw == null ? {} : Set.from(raw);
  }

  Future<void> _writeIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchlistKey, ids.toList());
  }

  Future<List<String>> getWatchlistIds() async {
    try {
      return _readIds().then((ids) => ids.toList());
    } catch (_) {
      return const [];
    }
  }

  Future<bool> addWatchlistId(String movieId) async {
    final ids = await _readIds();
    if (ids.contains(movieId)) return false;
    ids.add(movieId);
    await _writeIds(ids);
    return true;
  }

  Future<bool> removeWatchlistId(String movieId) async {
    final ids = await _readIds();
    if (!ids.contains(movieId)) return false;
    ids.remove(movieId);
    await _writeIds(ids);
    return true;
  }

  Future<bool> isWatched(String movieId) async {
    final ids = await _readIds();
    return ids.contains(movieId);
  }
}
