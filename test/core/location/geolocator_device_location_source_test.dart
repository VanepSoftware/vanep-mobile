import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/location/geolocator_device_location_source.dart';
import 'package:vanep_mobile/core/places/place_search_center.dart';

import 'location_fixtures.dart';

const taguatingaCenter = PlaceSearchCenter(
  latitude: -15.8333,
  longitude: -48.0564,
);

void main() {
  late MockGeolocatorPlatform geolocator;
  late GeolocatorDeviceLocationSource source;

  setUpAll(() => registerFallbackValue(const LocationSettings()));

  setUp(() {
    geolocator = MockGeolocatorPlatform();
    source = GeolocatorDeviceLocationSource(geolocator: geolocator);
    when(() => geolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(() => geolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => geolocator.getLastKnownPosition())
        .thenAnswer((_) async => fakePosition());
  });

  test('uses the last known position when permission is granted', () async {
    expect(await source.findApproximateLocation(), taguatingaCenter);
    verifyNever(() => geolocator.requestPermission());
    verifyNever(
      () => geolocator.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  test('asks for permission once when it was not decided yet', () async {
    when(() => geolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    when(() => geolocator.requestPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);

    expect(await source.findApproximateLocation(), taguatingaCenter);
    verify(() => geolocator.requestPermission()).called(1);
  });

  test('a refused permission request gives no location', () async {
    when(() => geolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    when(() => geolocator.requestPermission())
        .thenAnswer((_) async => LocationPermission.denied);

    expect(await source.findApproximateLocation(), isNull);
    verifyNever(() => geolocator.getLastKnownPosition());
  });

  test('a permanently denied permission is never asked again', () async {
    when(() => geolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.deniedForever);

    expect(await source.findApproximateLocation(), isNull);
    verifyNever(() => geolocator.requestPermission());
  });

  test('a disabled location service gives no location and no prompt', () async {
    when(() => geolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => false);

    expect(await source.findApproximateLocation(), isNull);
    verifyNever(() => geolocator.checkPermission());
  });

  test(
    'without a last known position it asks for a low accuracy fix',
    () async {
      when(() => geolocator.getLastKnownPosition())
          .thenAnswer((_) async => null);
      when(
        () => geolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => fakePosition());

      expect(await source.findApproximateLocation(), taguatingaCenter);
      final settings =
          verify(
                () => geolocator.getCurrentPosition(
                  locationSettings: captureAny(named: 'locationSettings'),
                ),
              ).captured.single
              as LocationSettings;
      expect(settings.accuracy, LocationAccuracy.low);
      expect(settings.timeLimit, const Duration(seconds: 5));
    },
  );

  test('a timeout gives no location', () async {
    when(() => geolocator.getLastKnownPosition()).thenAnswer((_) async => null);
    when(
      () => geolocator.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(TimeoutException('no fix'));

    expect(await source.findApproximateLocation(), isNull);
  });

  test('a platform error gives no location', () async {
    when(() => geolocator.checkPermission())
        .thenThrow(const PermissionDefinitionsNotFoundException('missing'));

    expect(await source.findApproximateLocation(), isNull);
  });
}
