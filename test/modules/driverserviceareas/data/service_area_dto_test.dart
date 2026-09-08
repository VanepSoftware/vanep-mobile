import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driverserviceareas/data/dtos/service_area_dto.dart';

import '../driver_service_areas_fixtures.dart';

void main() {
  test('a place chosen now travels as placeId with its session', () {
    expect(serviceAreaDraftToJson(testQnl5Draft), {
      'placeId': 'place-qnl5',
      'sessionToken': 'session-1',
    });
  });

  test('an already saved area travels as areaToken alone', () {
    expect(serviceAreaDraftToJson(testSavedQnl5Draft), {
      'areaToken': 'area-qnl5',
    });
  });

  test('a place without a session omits the field', () {
    expect(
      serviceAreaDraftToJson(draftsOfSize(1).single),
      isNot(contains('sessionToken')),
    );
  });
}
