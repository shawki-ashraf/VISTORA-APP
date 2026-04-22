import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://accept.paymob.com/api",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Generic POST method
  static Future<Response> post({
    required String endpoint,
    required String ApiKey,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data ?? "Something went wrong in POST request",
      );
    }
  }
}
