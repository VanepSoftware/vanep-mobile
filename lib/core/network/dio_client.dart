import 'package:dio/dio.dart';

/// Builds the shared [Dio] instances (constitution R09 — HTTP-client boundary).
class DioClient {
  const DioClient._();

  /// A base [Dio] pointed at [baseUrl] with sane timeouts. Used directly for
  /// the OAuth endpoints (token/profile/revoke); attach [AuthInterceptor] on a
  /// separate instance for authenticated API calls.
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
