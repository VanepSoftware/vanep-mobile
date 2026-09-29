import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';
import 'package:vanep_mobile/modules/driver_vans/data/datasources/driver_van_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_vans/data/repositories/driver_van_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';

import '../../../core/media/media_mocks.dart';
import '../driver_vans_fixtures.dart';
import '../driver_vans_mocks.dart';

class MockDio extends Mock implements Dio {}

class MockPhotoUploader extends Mock implements PhotoUploader {}

const environment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

DioException statusError(int? status) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<void>(requestOptions: RequestOptions(), statusCode: status),
);

void main() {
  group('DriverVanRemoteDataSource', () {
    late MockDio dio;
    late MockPhotoUploader uploader;
    late DriverVanRemoteDataSource remote;

    setUpAll(() => registerFallbackValue(testPickedPhoto));

    setUp(() {
      dio = MockDio();
      uploader = MockPhotoUploader();
      remote = DriverVanRemoteDataSource(
        dio: dio,
        environment: environment,
        photoUploader: uploader,
      );
    });

    test('lists the vans of the signed-in driver', () async {
      when(() => dio.get<List<dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [Map<String, dynamic>.of(testVanJson)],
        ),
      );

      final vans = await remote.fetchMyVans();

      expect(vans, [testVan]);
      verify(
        () => dio.get<List<dynamic>>('http://10.0.2.2:8080/api/vehicles/me'),
      ).called(1);
    });

    test(
      'registers a van with trimmed, typed and upper-cased values',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            data: Map<String, dynamic>.of(testVanJson),
          ),
        );

        final van = await remote.registerVan(validRegistration);

        expect(van, testVan);
        final body =
            verify(
                  () => dio.post<Map<String, dynamic>>(
                    'http://10.0.2.2:8080/api/vehicles/me',
                    data: captureAny(named: 'data'),
                  ),
                ).captured.single
                as Map<String, Object?>;
        expect(body, {
          'plate': 'ABC1D23',
          'brand': 'Mercedes-Benz',
          'model': 'Sprinter',
          'manufactureYear': 2021,
          'color': 'Branca',
          'capacity': 15,
        });
      },
    );

    test('sends each side of the van to its own route', () async {
      when(() => uploader.upload(any(), any())).thenAnswer((_) async {});

      await remote.uploadVanPhoto('van-1', VanPhotoSide.front, testPickedPhoto);
      await remote.uploadVanPhoto('van-1', VanPhotoSide.side, testPickedPhoto);

      verify(
        () => uploader.upload(
          'http://10.0.2.2:8080/api/vehicles/van-1/photo-front',
          testPickedPhoto,
        ),
      ).called(1);
      verify(
        () => uploader.upload(
          'http://10.0.2.2:8080/api/vehicles/van-1/photo-side',
          testPickedPhoto,
        ),
      ).called(1);
    });
  });

  group('DriverVanRepositoryImpl', () {
    late MockDriverVanRemoteDataSource remote;
    late DriverVanRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(validRegistration);
      registerFallbackValue(VanPhotoSide.front);
      registerFallbackValue(testPickedPhoto);
    });

    setUp(() {
      remote = MockDriverVanRemoteDataSource();
      repository = DriverVanRepositoryImpl(remote: remote);
    });

    test('returns the vans', () async {
      when(remote.fetchMyVans).thenAnswer((_) async => [testVan]);

      expect((await repository.listMyVans()).valueOrNull, [testVan]);
    });

    test('maps each registration answer to a failure', () async {
      final expectations = {
        409: DriverVanFailure.duplicatePlate,
        400: DriverVanFailure.invalidData,
        null: DriverVanFailure.network,
        500: DriverVanFailure.unexpected,
      };
      for (final entry in expectations.entries) {
        when(() => remote.registerVan(any())).thenThrow(statusError(entry.key));

        final result = await repository.registerVan(validRegistration);

        expect(result.errorOrNull, entry.value, reason: '${entry.key}');
      }
    });

    test('maps a refused photo to a photo failure', () async {
      when(
        () => remote.uploadVanPhoto(any(), any(), any()),
      ).thenThrow(statusError(400));

      final result = await repository.uploadVanPhoto(
        'van-1',
        VanPhotoSide.side,
        testPickedPhoto,
      );

      expect(result.errorOrNull, PhotoFailure.unsupportedType);
    });
  });
}
