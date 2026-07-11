import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/network/auth_interceptor.dart';

class MockDio extends Mock implements Dio {}

class MockRequestHandler extends Mock implements RequestInterceptorHandler {}

class MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

Response<dynamic> _response(int status, {required RequestOptions options}) =>
    Response<dynamic>(requestOptions: options, statusCode: status);

DioException _unauthorized() {
  final options = RequestOptions(path: '/api/user/profile');
  return DioException(
    requestOptions: options,
    response: _response(401, options: options),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
  });

  late MockDio retryClient;

  setUp(() => retryClient = MockDio());

  AuthInterceptor buildInterceptor({
    String? token,
    Future<String?> Function()? refresher,
  }) {
    return AuthInterceptor(
      readAccessToken: () => token,
      refreshAccessToken: refresher ?? () async => null,
      retryClient: retryClient,
    );
  }

  test('onRequest injects the bearer token when present', () {
    final interceptor = buildInterceptor(token: 'access-1');
    final handler = MockRequestHandler();
    final options = RequestOptions(path: '/api/user/profile');
    when(() => handler.next(any())).thenReturn(null);

    interceptor.onRequest(options, handler);

    final forwarded =
        verify(() => handler.next(captureAny())).captured.single
            as RequestOptions;
    expect(forwarded.headers['Authorization'], 'Bearer access-1');
  });

  test('onRequest leaves the request untouched when unauthenticated', () {
    final interceptor = buildInterceptor(token: null);
    final handler = MockRequestHandler();
    final options = RequestOptions(path: '/api/user/profile');
    when(() => handler.next(any())).thenReturn(null);

    interceptor.onRequest(options, handler);

    final forwarded =
        verify(() => handler.next(captureAny())).captured.single
            as RequestOptions;
    expect(forwarded.headers.containsKey('Authorization'), isFalse);
  });

  test('onError refreshes once and retries the request on 401', () async {
    final interceptor = buildInterceptor(refresher: () async => 'access-2');
    final handler = MockErrorHandler();
    final error = _unauthorized();
    final retried = _response(200, options: error.requestOptions);
    when(() => retryClient.fetch<dynamic>(any()))
        .thenAnswer((_) async => retried);
    when(() => handler.resolve(any())).thenReturn(null);

    await interceptor.onError(error, handler);

    final replayed =
        verify(() => retryClient.fetch<dynamic>(captureAny())).captured.single
            as RequestOptions;
    expect(replayed.headers['Authorization'], 'Bearer access-2');
    verify(() => handler.resolve(retried)).called(1);
  });

  test('onError forwards the error when refresh yields no token', () async {
    final interceptor = buildInterceptor(refresher: () async => null);
    final handler = MockErrorHandler();
    final error = _unauthorized();
    when(() => handler.next(any())).thenReturn(null);

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
    verifyNever(() => retryClient.fetch<dynamic>(any()));
  });

  test('onError passes non-401 errors straight through', () async {
    final interceptor = buildInterceptor(refresher: () async => 'access-2');
    final handler = MockErrorHandler();
    final options = RequestOptions(path: '/api/user/profile');
    final error = DioException(
      requestOptions: options,
      response: _response(500, options: options),
    );
    when(() => handler.next(any())).thenReturn(null);

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
  });
}
