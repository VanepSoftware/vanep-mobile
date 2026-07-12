import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.readAccessToken,
    required this.refreshAccessToken,
    required this.retryClient,
  });

  final String? Function() readAccessToken;

  final Future<String?> Function() refreshAccessToken;

  final Dio retryClient;

  static const _retriedFlag = 'auth_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newToken = await refreshAccessToken();
    if (newToken == null || newToken.isEmpty) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newToken'
      ..extra[_retriedFlag] = true;
    try {
      final response = await retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
