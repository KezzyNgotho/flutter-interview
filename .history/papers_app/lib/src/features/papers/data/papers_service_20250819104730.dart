import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/auth_storage.dart';

class PapersService {
  final ApiClient apiClient;
  final AuthStorage authStorage;

  PapersService({required this.apiClient, required this.authStorage});

  Future<String?> login({required String email, required String password}) async {
    try {
      final response = await apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'] as String?;
      if (token != null) {
        await authStorage.saveToken(token);
      }
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    }
  }

  Future<List<dynamic>> fetchSubjects() async {
    final token = await authStorage.readToken();
    final response = await apiClient.dio.get('/subjects', options: Options(headers: {
      'Authorization': 'Bearer $token',
    }));
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> fetchPapers({String? subjectId, String? year}) async {
    final token = await authStorage.readToken();
    final response = await apiClient.dio.get('/papers',
        queryParameters: {
          if (subjectId != null) 'subject_id': subjectId,
          if (year != null) 'year': year,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchPaperDetail(String paperId) async {
    final token = await authStorage.readToken();
    final response = await apiClient.dio.get('/papers/$paperId', options: Options(headers: {
      'Authorization': 'Bearer $token',
    }));
    return Map<String, dynamic>.from(response.data as Map);
  }
}

