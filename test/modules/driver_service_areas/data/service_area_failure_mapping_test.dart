import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/repositories/driver_service_area_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';

DioException dioFailure(int? statusCode, [Object? data]) {
  return DioException(
    requestOptions: RequestOptions(),
    response: statusCode == null
        ? null
        : Response<dynamic>(
            statusCode: statusCode,
            requestOptions: RequestOptions(),
            data: data,
          ),
  );
}

void main() {
  test('400 with the unmatched city code is cityUnmatched', () {
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'code': 'location.city.unmatched'}),
      ),
      ServiceAreaFailure.cityUnmatched,
    );
  });

  test('400 with the Portuguese unmatched detail is cityUnmatched', () {
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'detail':
              'Este nome de cidade não corresponde a um município brasileiro. '
              'Escolha outra sugestão.',
        }),
      ),
      ServiceAreaFailure.cityUnmatched,
    );
  });

  test('400 with the English unmatched detail is cityUnmatched', () {
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'detail':
              'This city name does not match a Brazilian municipality. '
              'Choose another suggestion.',
        }),
      ),
      ServiceAreaFailure.cityUnmatched,
    );
  });

  test('the other 400s keep their own failure', () {
    expect(
      serviceAreaFailureFrom(dioFailure(400, {'detail': 'não reconhecido'})),
      ServiceAreaFailure.placeNotResolved,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'detail': 'Esta cidade exige um bairro'}),
      ),
      ServiceAreaFailure.districtRequired,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'detail': 'Você pode ter no máximo 10 áreas.'}),
      ),
      ServiceAreaFailure.tooManyAreas,
    );
  });

  test('a 400 without a body stays placeNotResolved', () {
    expect(
      serviceAreaFailureFrom(dioFailure(400)),
      ServiceAreaFailure.placeNotResolved,
    );
  });
}
