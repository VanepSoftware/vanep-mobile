import 'package:dio/dio.dart';

const String authenticatedDioName = 'authenticatedDio';

class DioClient {
  const DioClient._();

  static Dio create(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }
}
