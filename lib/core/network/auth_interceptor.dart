import 'package:dio/dio.dart';

/// Attaches the bearer token to outgoing requests and transparently refreshes
/// it once on a 401 (constitution R09).
///
/// It stays decoupled from the auth module: [readAccessToken] and
/// [refreshAccessToken] are supplied by the composition root, so the token
/// stays owned by a single source (the auth repository / local store).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.readAccessToken,
    required this.refreshAccessToken,
    required this.retryClient,
  });

  /// Current access token, or `null` when the user is not authenticated.
  final String? Function() readAccessToken;

  /// Forces a refresh and returns the new access token, or `null` on failure.
  final Future<String?> Function() refreshAccessToken;

  /// A [Dio] without this interceptor, used to replay a request after refresh.
  final Dio retryClient;

  static const _retriedFlag = 'auth_retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
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
