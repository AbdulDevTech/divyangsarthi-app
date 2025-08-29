import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' show log;

class ApiClient {
  final Dio _dio;
  FlutterSecureStorage? _storage;
  final Map<String, String> _inMemoryStore = {};

  ApiClient._internal(this._dio) {
    _dio.options.baseUrl = 'https://backend.divyangsarthi.in';
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // attach token if available
        try {
          final token = await _safeRead('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['x-access-token'] = token;
          }
        } catch (e) {
          // don't block the request on storage failures; continue without token
        }

        // Log request details for debugging (payload, headers)
        try {
          log('API Request --> ${options.method.toUpperCase()} ${options.uri.toString()}', name: 'ApiClient');
          log('Request headers: ${options.headers}', name: 'ApiClient');
          log('Request data: ${options.data}', name: 'ApiClient');
        } catch (_) {}

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // Log response details
        try {
          log('API Response <-- ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri.toString()}', name: 'ApiClient');
          log('Status: ${response.statusCode}', name: 'ApiClient');
          log('Response data: ${response.data}', name: 'ApiClient');
        } catch (_) {}
        return handler.next(response);
      },
      onError: (err, handler) async {
        // Log error details
        try {
          final req = err.requestOptions;
          log('API Error XX ${req.method.toUpperCase()} ${req.uri.toString()}', name: 'ApiClient');
          log('Error message: ${err.message}', name: 'ApiClient');
          if (err.response != null) {
            log('Error status: ${err.response?.statusCode}', name: 'ApiClient');
            log('Error response data: ${err.response?.data}', name: 'ApiClient');
          }
        } catch (_) {}
        // TODO: implement refresh token flow using users/public/getaccesstoken
        return handler.next(err);
      },
    ));
  }

  Future<void> _ensureStorage() async {
    if (_storage != null) return;
    try {
      // On web flutter_secure_storage isn't supported; keep in-memory fallback
      if (kIsWeb) return;
      _storage = const FlutterSecureStorage();
    } catch (_) {
      // ignore and rely on in-memory store
    }
  }

  Future<void> _safeWrite(String key, String? value) async {
    await _ensureStorage();
    try {
      if (_storage != null) {
        await _storage!.write(key: key, value: value);
        return;
      }
    } catch (_) {
      // fallthrough to in-memory
    }
    if (value == null) {
      _inMemoryStore.remove(key);
    } else {
      _inMemoryStore[key] = value;
    }
  }

  Future<String?> _safeRead(String key) async {
    await _ensureStorage();
    try {
      if (_storage != null) {
        final v = await _storage!.read(key: key);
        if (v != null) return v;
      }
    } catch (_) {
      // ignore and fallback
    }
    return _inMemoryStore[key];
  }

  static ApiClient create() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return ApiClient._internal(dio);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// Attempt login with email and password. If successful, saves access_token
  /// into secure storage and returns the token string.
  /// Returns a map with keys: 'token' (String?) and 'user' (Map?) on success.
  Future<Map<String, dynamic>?> login(String emailOrPhone, String password) async {
    try {
      final payload = {'emailorphone': emailOrPhone, 'password': password};
      // avoid logging password in plain text; log only the field exists
      log('Login request -> /users/public/login payload keys: ${payload.keys}');
      final response = await post('/users/public/login', data: payload);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        final data = response.data;
        final parsed = _parseAuthResponse(data);
        final token = parsed['token'] as String?;
        final user = parsed['user'] as Map<String, dynamic>?;
        if (token != null && token.isNotEmpty) {
          await _safeWrite('access_token', token);
        }
        // also check top-level refresh token keys
        final topLevelRefresh = (data is Map) ? (data['refresh_token'] ?? data['refreshToken']) : null;
        final refresh = user != null ? (user['refresh_token'] ?? user['refreshToken'] ?? user['refresh'] ?? topLevelRefresh) : topLevelRefresh;
        if (refresh != null && refresh.toString().isNotEmpty) {
          await _safeWrite('refresh_token', refresh.toString());
        }
        return {'token': token, 'user': user};
      } else {
        throw Exception('Login failed: ${response.statusCode} ${response.data}');
      }
    } catch (e) {
      log('Login error: $e', name: 'ApiClient');
      rethrow; // or return null if you prefer to handle errors upstream
    }
  }

  /// Register a new user. On success, saves access_token if provided and
  /// returns the token string.
  /// Returns a map with keys: 'token' (String?) and 'user' (Map?) on success.
  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    final response = await post('/users/public/register', data: {'name': name, 'email': email, 'password': password});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final parsed = _parseAuthResponse(data);
      final token = parsed['token'] as String?;
      final user = parsed['user'] as Map<String, dynamic>?;
      if (token != null && token.isNotEmpty) {
        await _safeWrite('access_token', token);
      }
      return {'token': token, 'user': user};
    }
    throw Exception('Register failed: ${response.statusCode}');
  }

  // Helper to parse token and user/role from common response shapes
  Map<String, dynamic> _parseAuthResponse(dynamic data) {
    String? token;
    Map<String, dynamic>? user;

    if (data is Map<String, dynamic>) {
      // token may be under different keys (snake_case or camelCase)
      token = (data['access_token'] ?? data['accessToken'] ?? data['token'])?.toString();

      // refresh token if present (collect now, merge later)
      final refresh = (data['refresh_token'] ?? data['refreshToken'])?.toString();

      // Common locations for user/role
      if (data['user'] is Map<String, dynamic>) {
        user = Map<String, dynamic>.from(data['user']);
      } else if (data.containsKey('role')) {
        user = {'role': data['role']};
      } else if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        if (inner['user'] is Map<String, dynamic>) user = Map<String, dynamic>.from(inner['user']);
        if (user == null && inner.containsKey('role')) user = {'role': inner['role']};
      } else if (data['roles'] is List && (data['roles'] as List).isNotEmpty) {
        user = {'role': (data['roles'] as List).first.toString()};
      } else if (data['roles'] is String && data['roles'].toString().isNotEmpty) {
        // some APIs return roles as a single string
        user = {'role': data['roles'].toString()};
      } else {
        // If the response contains user-like top-level fields, assemble a minimal user map
        final keys = ['firstName', 'lastName', 'email', 'mobile', 'id', 'roles', 'role', 'userDP'];
        final candidate = <String, dynamic>{};
        for (final k in keys) {
          if (data.containsKey(k)) candidate[k] = data[k];
        }
        if (candidate.isNotEmpty) user = candidate;
      }

      // Merge refresh token into user map if available
      if (refresh != null && refresh.isNotEmpty) {
        user ??= <String, dynamic>{};
        user['refresh_token'] = refresh;
      }
    }

    return {'token': token, 'user': user};
  }
}
