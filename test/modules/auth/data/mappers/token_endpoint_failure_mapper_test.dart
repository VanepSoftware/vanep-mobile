import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/mappers/token_endpoint_failure_mapper.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';

DioException tokenEndpointError(int status, Object? body) {
  final options = RequestOptions(path: '/oauth2/token');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

void main() {
  test('no response is a network failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/oauth2/token'),
      type: DioExceptionType.connectionError,
      message: 'offline',
    );

    expect(mapTokenEndpointFailure(error), const NetworkAuthFailure('offline'));
  });

  test('429 is a too many requests failure', () {
    final error = tokenEndpointError(429, 'Muitas tentativas.');

    expect(mapTokenEndpointFailure(error), const TooManyRequestsAuthFailure());
  });

  final errorCodes = <String, AuthFailure>{
    'invalid_grant': const InvalidCredentialsAuthFailure(),
    'email_not_verified': const EmailNotVerifiedAuthFailure(),
    'account_locked': const AccountLockedAuthFailure(),
    'account_disabled': const AccountDisabledAuthFailure(),
  };

  for (final entry in errorCodes.entries) {
    test('${entry.key} maps to ${entry.value.runtimeType}', () {
      final error = tokenEndpointError(400, {
        'error': entry.key,
        'error_description': 'server text',
      });

      expect(mapTokenEndpointFailure(error), entry.value);
    });
  }

  test('an unknown OAuth error is unexpected', () {
    final error = tokenEndpointError(400, {'error': 'unsupported_grant_type'});

    expect(
      mapTokenEndpointFailure(error),
      const UnexpectedAuthFailure('unsupported_grant_type'),
    );
  });

  test('a server error without OAuth body is unexpected', () {
    final error = tokenEndpointError(500, 'boom');

    expect(mapTokenEndpointFailure(error), isA<UnexpectedAuthFailure>());
  });
}
