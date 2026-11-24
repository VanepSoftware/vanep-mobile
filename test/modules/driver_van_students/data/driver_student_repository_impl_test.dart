import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/repositories/driver_student_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';

DioException _error(int? statusCode, [Object? data]) {
  final options = RequestOptions(path: '/api/driver/students');
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
  test('maps known not-found codes to DriverStudentNotFoundFailure', () {
    expect(
      driverStudentFailureFrom(
        _error(404, {'code': ApiErrorCodes.unlinkedPassengerNotFound}),
      ),
      const DriverStudentNotFoundFailure(),
    );
    expect(
      driverStudentFailureFrom(
        _error(404, {'code': ApiErrorCodes.driverStudentVehicleNotFound}),
      ),
      const DriverStudentNotFoundFailure(),
    );
  });

  test('maps known rejected/validation codes carrying detail', () {
    expect(
      driverStudentFailureFrom(
        _error(422, {
          'code': ApiErrorCodes.unlinkedPassengerVehicleNotOwned,
          'detail': 'Veículo não pertence ao motorista.',
        }),
      ),
      const DriverStudentRejectedFailure(
        detail: 'Veículo não pertence ao motorista.',
      ),
    );
    expect(
      driverStudentFailureFrom(
        _error(400, {
          'code': ApiErrorCodes.validationFailed,
          'detail': 'Informe o nome do aluno.',
        }),
      ),
      const DriverStudentRejectedFailure(detail: 'Informe o nome do aluno.'),
    );
  });

  test('falls back cleanly for unknown code, empty body and network', () {
    expect(
      driverStudentFailureFrom(_error(null)),
      const DriverStudentNetworkFailure(),
    );
    expect(
      driverStudentFailureFrom(_error(404, {'code': 'unknown.code'})),
      const DriverStudentNotFoundFailure(),
    );
    expect(
      driverStudentFailureFrom(
        _error(422, {'code': 'unknown.code', 'detail': 'Regra violada.'}),
      ),
      const DriverStudentRejectedFailure(detail: 'Regra violada.'),
    );
    expect(
      driverStudentFailureFrom(_error(400)),
      const DriverStudentUnexpectedFailure(),
    );
    expect(
      driverStudentFailureFrom(_error(500)),
      const DriverStudentUnexpectedFailure(),
    );
  });
}
