import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrowbe_app/core/network/api_client.dart';

/// Outfit suggestion state
class OutfitState {
  final bool isLoading;
  final Map<String, dynamic>? currentSuggestion;
  final List<Map<String, dynamic>> history;
  final String? errorMessage;

  const OutfitState({
    this.isLoading = false,
    this.currentSuggestion,
    this.history = const [],
    this.errorMessage,
  });

  OutfitState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentSuggestion,
    List<Map<String, dynamic>>? history,
    String? errorMessage,
  }) {
    return OutfitState(
      isLoading: isLoading ?? this.isLoading,
      currentSuggestion: currentSuggestion ?? this.currentSuggestion,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class OutfitNotifier extends StateNotifier<OutfitState> {
  final ApiClient _api;

  OutfitNotifier(this._api) : super(const OutfitState());

  /// Request a new outfit suggestion
  Future<void> suggest({required String occasion}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.dio.post('/outfits/suggest', data: {
        'occasion': occasion,
      });
      state = OutfitState(currentSuggestion: response.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Get today's outfit
  Future<void> loadTodayOutfit() async {
    try {
      final response = await _api.dio.get('/outfits/today');
      state = state.copyWith(currentSuggestion: response.data);
    } catch (_) {
      // No outfit for today — that's fine
    }
  }

  /// Get outfit history
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.dio.get('/outfits/history');
      final List<dynamic> data = response.data ?? [];
      state = OutfitState(
        history: data.cast<Map<String, dynamic>>(),
        currentSuggestion: state.currentSuggestion,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Accept or reject an outfit
  Future<void> respond(String outfitId, bool accepted) async {
    try {
      await _api.dio.post('/outfits/$outfitId/respond', data: {
        'accepted': accepted,
      });
      if (accepted) {
        await loadHistory();
      }
    } catch (_) {}
  }

  /// Give feedback on an outfit
  Future<void> feedback(String outfitId, int rating, String? comment) async {
    try {
      await _api.dio.post('/outfits/$outfitId/feedback', data: {
        'rating': rating,
        'comment': comment,
      });
    } catch (_) {}
  }

  void clearSuggestion() {
    state = OutfitState(history: state.history);
  }
}

/// Outfit state provider
final outfitProvider = StateNotifierProvider<OutfitNotifier, OutfitState>((ref) {
  final api = ref.read(apiClientProvider);
  return OutfitNotifier(api);
});
