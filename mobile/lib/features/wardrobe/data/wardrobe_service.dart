import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrowbe_app/core/network/api_client.dart';

/// Wardrobe items state
class WardrobeState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? errorMessage;

  const WardrobeState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  WardrobeState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, String? errorMessage}) {
    return WardrobeState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  int get totalItems => items.length;
  int get needsWashCount => items.where((i) => i['needsWash'] == true).length;

  List<Map<String, dynamic>> filterByType(String? type) {
    if (type == null || type == 'All') return items;
    return items.where((i) => i['type'] == type).toList();
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final ApiClient _api;

  WardrobeNotifier(this._api) : super(const WardrobeState());

  /// Fetch all items for the current user
  Future<void> loadItems({String? type}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final queryParams = <String, dynamic>{'size': 100};
      if (type != null && type != 'All') queryParams['type'] = type;

      final response = await _api.dio.get('/items', queryParameters: queryParams);
      final data = response.data;

      // The API returns a Page<ClothingItem> — extract content
      final List<dynamic> content = data['content'] ?? data ?? [];
      state = WardrobeState(
        items: content.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Create a new clothing item
  Future<bool> addItem({required String name, String? imagePath}) async {
    try {
      await _api.dio.post('/items', data: {
        'name': name,
        'imagePath': imagePath ?? '',
      });
      await loadItems(); // Refresh
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete an item
  Future<bool> deleteItem(String id) async {
    try {
      await _api.dio.delete('/items/$id');
      await loadItems(); // Refresh
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Log wearing an item
  Future<bool> logWear(String id) async {
    try {
      await _api.dio.post('/items/$id/wear');
      await loadItems();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark an item as washed
  Future<bool> markWashed(String id) async {
    try {
      await _api.dio.post('/items/$id/wash');
      await loadItems();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Wardrobe state provider
final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  final api = ref.read(apiClientProvider);
  return WardrobeNotifier(api);
});
