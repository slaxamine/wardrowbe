import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrowbe_app/core/network/api_client.dart';

/// Authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, Map<String, dynamic>? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasToken = await _api.hasToken();
    if (hasToken) {
      try {
        final response = await _api.dio.get('/users/me');
        state = AuthState(status: AuthStatus.authenticated, user: response.data);
      } catch (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _api.dio.post('/users/signup', data: {
        'username': username,
        'email': email,
        'password': password,
        'name': name,
      });
      // Auto-login after signup
      return await login(username: username, password: password);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: _parseError(e));
      return false;
    }
  }

  /// Login with username/password → receive JWT from Keycloak
  Future<bool> login({required String username, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _api.dio.post('/users/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      await _api.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );

      // Fetch user profile
      final profileResponse = await _api.dio.get('/users/me');
      state = AuthState(status: AuthStatus.authenticated, user: profileResponse.data);
      return true;
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: _parseError(e));
      return false;
    }
  }

  /// Logout — clear tokens
  Future<void> logout() async {
    await _api.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Something went wrong';
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.read(apiClientProvider);
  return AuthNotifier(api);
});
