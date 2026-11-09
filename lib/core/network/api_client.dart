import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/')) {
            final refreshed = await _refresh();
            if (refreshed) {
              final token = await _storage.read(key: 'accessToken');
              final req = error.requestOptions;
              req.headers['Authorization'] = 'Bearer $token';
              final clone = await _dio.fetch(req);
              return handler.resolve(clone);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final FlutterSecureStorage _storage;
  late final Dio _dio;
  bool _refreshing = false;

  Dio get dio => _dio;

  Future<bool> _refresh() async {
    if (_refreshing) return false;
    _refreshing = true;
    try {
      final refresh = await _storage.read(key: 'refreshToken');
      if (refresh == null) return false;
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)).post(
        '/v1/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      await _storage.write(key: 'accessToken', value: data['accessToken'] as String);
      await _storage.write(key: 'refreshToken', value: data['refreshToken'] as String);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: 'accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<String?> readRefreshToken() => _storage.read(key: 'refreshToken');
}
