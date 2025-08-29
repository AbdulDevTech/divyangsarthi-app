import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient._internal(this._dio) {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://backend.divyangsarthi.in';
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        // TODO: implement refresh token flow using users/public/getaccesstoken
        return handler.next(err);
      },
    ));
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
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await post('/users/public/login', data: {'email': email, 'password': password});
    if (response.statusCode == 200) {
      final data = response.data;
      final parsed = _parseAuthResponse(data);
      final token = parsed['token'] as String?;
      final user = parsed['user'] as Map<String, dynamic>?;
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: 'access_token', value: token);
      }
      return {'token': token, 'user': user};
    }
    throw Exception('Login failed: ${response.statusCode}');
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
        await _storage.write(key: 'access_token', value: token);
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

      // refresh token if present
      final refresh = (data['refresh_token'] ?? data['refreshToken'])?.toString();
      if (refresh != null && refresh.isNotEmpty) {
        // save under a normalized key if present
        user ??= <String, dynamic>{};
        user['refresh_token'] = refresh;
      }

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
    }

    return {'token': token, 'user': user};
  }
}
