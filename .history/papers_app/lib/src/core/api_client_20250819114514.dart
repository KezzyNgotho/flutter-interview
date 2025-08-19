import 'package:dio/dio.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient({required this.authStorage}) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Surface friendly messages
          if (e.response?.statusCode == 401) {
            await authStorage.clear();
          }
          handler.next(e);
        },
      ),
    );
  }

  final AuthStorage authStorage;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment('API_BASE', defaultValue: 'http://127.0.0.1:8000/api'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Dio get dio => _dio;
}
