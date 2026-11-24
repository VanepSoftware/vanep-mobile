import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';

DioException _dioError(int? statusCode, Object? data) {
  final options = RequestOptions(path: '/api/test');
  return DioException(
    requestOptions: options,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: options,
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  test('parses ProblemDetail with code, detail, field, errors and extras', () {
    final problem = ApiProblem.fromDioException(
      _dioError(400, {
        'type': 'about:blank',
        'title': 'Bad Request',
        'status': 400,
        'detail': 'Payload inválido.',
        'instance': '/api/user/me',
        'code': ApiErrorCodes.validationFailed,
        'field': 'name',
        'retryAfter': '2026-09-01T12:00:00Z',
        'errors': [
          {
            'field': 'areas',
            'code': ApiErrorCodes.driverServiceAreaAreasTooMany,
            'message': 'Máximo de 10 áreas.',
          },
          'malformed-entry',
        ],
      }),
    );

    expect(problem.status, 400);
    expect(problem.title, 'Bad Request');
    expect(problem.detail, 'Payload inválido.');
    expect(problem.code, ApiErrorCodes.validationFailed);
    expect(problem.field, 'name');
    expect(problem.isNetworkFailure, isFalse);
    expect(problem.matchesCode(ApiErrorCodes.validationFailed), isTrue);
    expect(
      problem.matchesCode(ApiErrorCodes.driverServiceAreaAreasTooMany),
      isTrue,
    );
    expect(
      problem.hasCode(ApiErrorCodes.driverServiceAreaAreasTooMany),
      isFalse,
    );
    expect(
      problem.hasErrorCode(ApiErrorCodes.driverServiceAreaAreasTooMany),
      isTrue,
    );
    expect(problem.errors, hasLength(1));
    expect(problem.errors.single.field, 'areas');
    expect(problem.errors.single.message, 'Máximo de 10 áreas.');
    expect(
      problem.readDateTimeExtra('retryAfter'),
      DateTime.utc(2026, 9, 1, 12),
    );
  });

  test('falls back to legacy message when detail is absent', () {
    final problem = ApiProblem.fromResponseBody({
      'code': 'legacy_code',
      'message': 'Mensagem legada.',
    }, statusCode: 409);

    expect(problem.status, 409);
    expect(problem.code, 'legacy_code');
    expect(problem.detailText, 'Mensagem legada.');
  });

  test('handles null response, non-map body and missing fields safely', () {
    final network = ApiProblem.fromDioException(_dioError(null, null));
    expect(network.isNetworkFailure, isTrue);
    expect(network.status, isNull);
    expect(network.detailText, isEmpty);
    expect(network.code, isNull);

    final html = ApiProblem.fromDioException(
      _dioError(502, '<html>502</html>'),
    );
    expect(html.isNetworkFailure, isFalse);
    expect(html.status, 502);
    expect(html.code, isNull);
    expect(html.detail, isNull);
    expect(html.errors, isEmpty);

    final blankCode = ApiProblem.fromResponseBody({
      'code': '   ',
      'detail': '',
    });
    expect(blankCode.code, isNull);
    expect(blankCode.detail, isNull);
    expect(blankCode.detailText, isEmpty);
  });
}
