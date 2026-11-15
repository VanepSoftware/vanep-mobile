import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_search_center.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_search_center.dart';

import '../../auth/presentation/auth_presentation_mocks.dart';
import '../../auth/personal_address_fixture.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const goianiaCenter = PlaceSearchCenter(
  latitude: -16.6864,
  longitude: -49.2643,
);
const deviceCenter = PlaceSearchCenter(latitude: -15.8333, longitude: -48.0564);

void main() {
  late MockFindMyPersonalAddress findMyPersonalAddress;
  late MockDeviceLocationSource deviceLocation;
  late FindSchoolSearchCenter findSchoolSearchCenter;

  setUp(() {
    findMyPersonalAddress = MockFindMyPersonalAddress();
    deviceLocation = MockDeviceLocationSource();
    findSchoolSearchCenter = FindSchoolSearchCenter(
      findMyPersonalAddress: findMyPersonalAddress,
      deviceLocation: deviceLocation,
    );
  });

  void stubPersonalAddressAtGoiania() {
    when(() => findMyPersonalAddress()).thenAnswer(
      (_) async => Ok(
        fakePersonalAddress(
          cityLatitude: goianiaCenter.latitude,
          cityLongitude: goianiaCenter.longitude,
        ),
      ),
    );
  }

  test(
    'the dependent address city wins without asking anything else',
    () async {
      final center = await findSchoolSearchCenter(testDependentInBrasilia);

      expect(
        center,
        const PlaceSearchCenter(latitude: -15.7843, longitude: -47.9081),
      );
      verifyNever(() => findMyPersonalAddress());
      verifyNever(() => deviceLocation.findApproximateLocation());
    },
  );

  test(
    'the client address city is next, without touching the device location',
    () async {
      stubPersonalAddressAtGoiania();

      final center = await findSchoolSearchCenter(
        testDependentWithAddressWithoutCoordinates,
      );

      expect(center, goianiaCenter);
      verifyNever(() => deviceLocation.findApproximateLocation());
    },
  );

  test('the device location is used when no address has a point', () async {
    when(() => findMyPersonalAddress())
        .thenAnswer((_) async => Ok(fakePersonalAddress()));
    when(() => deviceLocation.findApproximateLocation())
        .thenAnswer((_) async => deviceCenter);

    final center = await findSchoolSearchCenter(testHelenaDependent);

    expect(center, deviceCenter);
  });

  test(
    'a client without a personal address falls through to the device',
    () async {
      when(() => findMyPersonalAddress())
          .thenAnswer((_) async => const Ok(null));
      when(() => deviceLocation.findApproximateLocation())
          .thenAnswer((_) async => deviceCenter);

      final center = await findSchoolSearchCenter(testHelenaDependent);

      expect(center, deviceCenter);
    },
  );

  test('a personal address failure falls through to the device', () async {
    when(() => findMyPersonalAddress())
        .thenAnswer((_) async => const Err(PersonalAddressFailure.network));
    when(() => deviceLocation.findApproximateLocation())
        .thenAnswer((_) async => deviceCenter);

    final center = await findSchoolSearchCenter(testHelenaDependent);

    expect(center, deviceCenter);
  });

  test('without any point the search keeps no center', () async {
    when(() => findMyPersonalAddress()).thenAnswer((_) async => const Ok(null));
    when(() => deviceLocation.findApproximateLocation())
        .thenAnswer((_) async => null);

    final center = await findSchoolSearchCenter(testHelenaDependent);

    expect(center, isNull);
  });

  test('a point needs both coordinates', () {
    expect(placeSearchCenterOrNull(-15.7843, null), isNull);
    expect(placeSearchCenterOrNull(null, -47.9081), isNull);
    expect(
      placeSearchCenterOrNull(-15.7843, -47.9081),
      const PlaceSearchCenter(latitude: -15.7843, longitude: -47.9081),
    );
  });
}
