import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/mappers/profile_edit_failure_mapper.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';

void main() {
  test('maps 400 phone_blank by code', () {
    final failure = mapProfileEditDioException(
      DioException(
        requestOptions: RequestOptions(path: '/api/user/me'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/api/user/me'),
          statusCode: 400,
          data: {
            'message': 'blank',
            'code': 'phone_blank',
            'field': 'phone',
          },
        ),
      ),
    );

    expect(
      failure,
      const StructuredProfileEditFailure(
        code: ProfileErrorCode.phoneBlank,
        field: 'phone',
      ),
    );
  });

  test('falls back to network when code is missing', () {
    final failure = mapProfileEditDioException(
      DioException(
        requestOptions: RequestOptions(path: '/api/user/me'),
        message: 'offline',
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/api/user/me'),
          statusCode: 400,
          data: {'message': 'bad'},
        ),
      ),
    );

    expect(failure, isA<NetworkProfileEditFailure>());
  });
}
