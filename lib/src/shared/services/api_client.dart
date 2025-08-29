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
}
