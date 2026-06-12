import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SearchHistoryController extends StateNotifier<List<String>> {
  SearchHistoryController(this._box) : super(_readSearches(_box));

  static const String _storageKey = 'items';
  static const int _maxItems = 8;

  final Box<dynamic> _box;

  Future<void> add(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return;

    final lowerQuery = normalized.toLowerCase();
    final updated = <String>[
      normalized,
      ...state.where((item) => item.toLowerCase() != lowerQuery),
    ].take(_maxItems).toList(growable: false);

    state = updated;
    await _box.put(_storageKey, updated);
  }

  Future<void> remove(String query) async {
    final lowerQuery = query.toLowerCase();
    final updated = state
        .where((item) => item.toLowerCase() != lowerQuery)
        .toList(growable: false);

    state = updated;
    await _box.put(_storageKey, updated);
  }

  Future<void> clear() async {
    state = const <String>[];
    await _box.put(_storageKey, state);
  }

  static List<String> _readSearches(Box<dynamic> box) {
    final stored = box.get(_storageKey);
    if (stored is! List) return const <String>[];

    return stored
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .take(_maxItems)
        .toList(growable: false);
  }
}
