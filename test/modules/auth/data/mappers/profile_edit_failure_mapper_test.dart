import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/mappers/profile_edit_failure_mapper.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';

DioException _dioError(int? statusCode, {Object? data, String? message}) {
  final options = RequestOptions(path: '/api/user/me');
  return DioException(
    requestOptions: options,
    message: message,
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
  test(
    'maps ProblemDetail phone_blank, cooldown and email duplicate codes',
    () {
      expect(
        mapProfileEditDioException(
          _dioError(
            400,
            data: {
              'status': 400,
              'detail': 'Informe o telefone.',
              'code': 'user.profile.phone.blank',
              'field': 'phone',
            },
          ),
        ),
        const StructuredProfileEditFailure(
          code: ProfileErrorCode.phoneBlank,
          field: 'phone',
        ),
      );

      final cooldown = mapProfileEditDioException(
        _dioError(
          409,
          data: {
            'status': 409,
            'detail': 'Aguarde antes de alterar novamente.',
            'code': 'user.profile.name.cooldown',
            'field': 'name',
            'retryAfter': '2026-09-01T12:00:00.000Z',
          },
        ),
      );
      expect(
        cooldown,
        StructuredProfileEditFailure(
          code: ProfileErrorCode.cooldown,
          field: 'name',
          retryAfter: DateTime.parse('2026-09-01T12:00:00.000Z'),
        ),
      );

      final duplicate = mapProfileEditDioException(
        _dioError(
          409,
          data: {
            'status': 409,
            'detail': 'E-mail já utilizado.',
            'code': 'auth.signup.email.duplicate',
            'field': 'email',
          },
        ),
      );
      expect(
        duplicate,
        const StructuredProfileEditFailure(
          code: ProfileErrorCode.emailDuplicate,
          field: 'email',
        ),
      );
    },
  );

  test('maps validation.failed ProblemDetail via errors[] entry code', () {
    final failure = mapProfileEditDioException(
      _dioError(
        400,
        data: {
          'status': 400,
          'detail': 'Dados inválidos.',
          'code': 'validation.failed',
          'errors': [
            {
              'field': 'email',
              'code': 'user.profile.email.invalid',
              'message': 'Informe um e-mail válido.',
            },
          ],
        },
      ),
    );

    expect(
      failure,
      const StructuredProfileEditFailure(
        code: ProfileErrorCode.emailInvalid,
        field: 'email',
      ),
    );
  });

  test(
    'maps legacy, unknown or missing code on HTTP response to unexpected',
    () {
      expect(
        mapProfileEditDioException(
          _dioError(400, data: {'detail': 'bad', 'code': 'phone_blank'}),
        ),
        const UnexpectedProfileEditFailure('bad'),
      );
      expect(
        mapProfileEditDioException(
          _dioError(400, data: {'detail': 'bad', 'code': 'unknown.code'}),
        ),
        const UnexpectedProfileEditFailure('bad'),
      );
      expect(
        mapProfileEditDioException(_dioError(500, message: 'server boom')),
        const UnexpectedProfileEditFailure('server boom'),
      );
    },
  );

  test('maps missing HTTP response to NetworkProfileEditFailure', () {
    expect(
      mapProfileEditDioException(_dioError(null, message: 'offline')),
      const NetworkProfileEditFailure('offline'),
    );
  });
}
