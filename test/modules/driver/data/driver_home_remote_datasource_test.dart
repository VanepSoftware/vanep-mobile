import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver/data/datasources/driver_home_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver/data/repositories/driver_home_repository_impl.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

class MockDio extends Mock implements Dio {}

const testEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

void main() {
  late MockDio dio;
  late DriverHomeRemoteDataSource remote;
  late DriverHomeRepositoryImpl repository;

  setUp(() {
    dio = MockDio();
    remote = DriverHomeRemoteDataSource(dio: dio, environment: testEnvironment);
    repository = DriverHomeRepositoryImpl(remote: remote);
  });

  test('unsupported stop confirmation never sends an HTTP request', () async {
    await expectLater(
      remote.confirmStop(
        const StopConfirmation(
          tripId: 'trip',
          stopId: 'stop',
          studentId: 'student',
          studentName: 'Ana',
          action: StopAction.boarding,
        ),
      ),
      throwsUnsupportedError,
    );
    verifyZeroInteractions(dio);
  });

  test('unknown trip cannot start a default morning shift', () async {
    await expectLater(remote.startTrip('unknown'), throwsStateError);
    verifyZeroInteractions(dio);
  });

  test(
    'load maps incomplete onboarding without calling trips endpoint',
    () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          testEnvironment.driverOnboardingEndpoint,
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {
            'driverToken': 'driver-1',
            'approvalStatus': 'PENDING',
            'canSubmit': false,
            'cnhStep': {
              'completed': false,
              'pendingItems': ['cnh_expired'],
            },
          },
        ),
      );

      final data = await repository.load();

      expect(data.registration, RegistrationStatus.incomplete);
      expect(data.expiredDocument, isTrue);
      expect(data.todayTrip, isNull);
      verifyNever(
        () => dio.get<List<dynamic>>(testEnvironment.driverTripsTodayEndpoint),
      );
    },
  );

  test('load composes approved driver trips and active client links', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        testEnvironment.driverOnboardingEndpoint,
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {
          'driverToken': 'driver-1',
          'approvalStatus': 'APPROVED',
          'canSubmit': false,
          'cnhStep': {'completed': true, 'pendingItems': <String>[]},
        },
      ),
    );

    when(() => dio.get<List<dynamic>>(testEnvironment.driverTripsTodayEndpoint))
        .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: [
              {
                'token': 'trip-morning-1',
                'shift': 'MORNING',
                'status': 'SCHEDULED',
                'outsideWorkWindow': true,
              },
            ],
          ),
        );

    when(() => dio.get<List<dynamic>>(testEnvironment.clientDriversMeEndpoint))
        .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: [
              {'token': 'link-1', 'status': 'ACTIVE'},
              {'token': 'link-2', 'status': 'ACTIVE'},
              {'token': 'link-3', 'status': 'PENDING'},
            ],
          ),
        );

    when(
      () => dio.post<Map<String, dynamic>>(
        testEnvironment.driverTripsStartEndpoint,
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {'token': 'trip-morning-1', 'status': 'IN_PROGRESS'},
      ),
    );

    final data = await repository.load();

    expect(data.registration, RegistrationStatus.approved);
    expect(data.todayTrip?.id, 'trip-morning-1');
    expect(data.todayTrip?.status, TripStatus.notStarted);
    expect(data.todayTrip?.label, 'MORNING');
    expect(data.outsideWorkingHours, isTrue);
    expect(data.studentCount, 2);
    expect(data.familiesInApp, isNull);
    expect(data.nextConfirmation, isNull);
    expect(data.contactLabel, isNull);

    await repository.startTrip('trip-morning-1');
    verify(
      () => dio.post<Map<String, dynamic>>(
        testEnvironment.driverTripsStartEndpoint,
        data: {'shift': 'MORNING'},
      ),
    ).called(1);
  });
}
