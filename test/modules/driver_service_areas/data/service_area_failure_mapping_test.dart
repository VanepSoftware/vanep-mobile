import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';
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
  test('maps known backend codes strictly regardless of detail text', () {
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'code': ApiErrorCodes.locationCityUnmatched}),
      ),
      ServiceAreaFailure.cityUnmatched,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'code': ApiErrorCodes.driverServiceAreaDistrictRequired,
        }),
      ),
      ServiceAreaFailure.districtRequired,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'code': ApiErrorCodes.validationFailed,
          'errors': [
            {
              'field': 'areas',
              'code': ApiErrorCodes.driverServiceAreaAreasTooMany,
              'message': 'Você pode ter no máximo 10 áreas.',
            },
          ],
        }),
      ),
      ServiceAreaFailure.tooManyAreas,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(429, {'code': ApiErrorCodes.locationPlaceRateLimited}),
      ),
      ServiceAreaFailure.rateLimited,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'code': ApiErrorCodes.driverServiceAreaAreaTokenUnknown,
        }),
      ),
      ServiceAreaFailure.placeNotResolved,
    );
  });

  test('does not infer domain variants from detail text alone', () {
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {
          'detail':
              'Este nome de cidade não corresponde a um município brasileiro.',
        }),
      ),
      ServiceAreaFailure.placeNotResolved,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'detail': 'Esta cidade exige um bairro'}),
      ),
      ServiceAreaFailure.placeNotResolved,
    );
    expect(
      serviceAreaFailureFrom(
        dioFailure(400, {'detail': 'Você pode ter no máximo 10 áreas.'}),
      ),
      ServiceAreaFailure.placeNotResolved,
    );
  });

  test('falls back by HTTP status on unknown codes or empty bodies', () {
    expect(
      serviceAreaFailureFrom(dioFailure(400, {'code': 'unknown.code'})),
      ServiceAreaFailure.placeNotResolved,
    );
    expect(
      serviceAreaFailureFrom(dioFailure(400)),
      ServiceAreaFailure.placeNotResolved,
    );
    expect(
      serviceAreaFailureFrom(dioFailure(429)),
      ServiceAreaFailure.rateLimited,
    );
    expect(
      serviceAreaFailureFrom(dioFailure(500)),
      ServiceAreaFailure.unexpected,
    );
    expect(
      serviceAreaFailureFrom(dioFailure(null)),
      ServiceAreaFailure.network,
    );
  });
}
