import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API client wired to the Spring Cloud Gateway.
class ApiClient {
  // Web/desktop uses localhost, Android emulator needs 10.0.2.2
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8600/api/v1' : 'http://10.0.2.2:8600/api/v1';

  static String get _keycloakBaseUrl =>
      kIsWeb ? 'http://localhost:8181' : 'http://10.0.2.2:8181';

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // JWT auth interceptor — auto-attaches Bearer token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired — try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request with new token
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));

    // Logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  /// Save JWT tokens after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  /// Check if user has a valid token
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Refresh the access token using the refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Call Keycloak token endpoint directly (not through our API)
      final refreshDio = Dio();
      final response = await refreshDio.post(
        '$_keycloakBaseUrl/realms/smartwardrobe/protocol/openid-connect/token',
        data: 'grant_type=refresh_token'
            '&client_id=wardrobe-app'
            '&client_secret=smartwardrobe-secret'
            '&refresh_token=$refreshToken',
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      if (response.statusCode == 200) {
        await saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      print('[API] Token refresh failed: $e');
    }
    return false;
  }
}

/// Global API client provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
