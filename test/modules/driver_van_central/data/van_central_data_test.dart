import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/datasources/van_central_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/repositories/van_central_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';

import '../driver_van_central_data_fixtures.dart';
import '../driver_van_central_mocks.dart';

const environment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

Response<T> okResponse<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(), data: data);

DioException statusError(int? status) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<void>(requestOptions: RequestOptions(), statusCode: status),
);

void main() {
  group('VanCentralRemoteDataSource', () {
    late MockDio dio;
    late VanCentralRemoteDataSource remote;

    setUp(() {
      dio = MockDio();
      remote = VanCentralRemoteDataSource(dio: dio, environment: environment);
    });

    test('reads the occupancy per shift of the signed-in driver', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(Map<String, dynamic>.of(occupancyJson)),
      );

      final occupancy = await remote.fetchOccupancy();

      expect(occupancy.students, 28);
      expect(occupancy.studentsWithFamily, 24);
      expect(occupancy.shifts.map((shift) => shift.shift), [
        OperationShift.morning,
        OperationShift.afternoon,
        OperationShift.night,
      ]);
      expect(occupancy.shifts.map((shift) => shift.passengers), [16, 12, 0]);
      verify(
        () => dio.get<Map<String, dynamic>>(
          'http://10.0.2.2:8080/api/drivers/me/occupancy',
        ),
      ).called(1);
    });

    test('skips a shift it does not know instead of failing', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(<String, dynamic>{
          'shifts': [
            {'shift': 'MORNING', 'passengers': 2},
            {'shift': 'EVENING', 'passengers': 9},
          ],
          'students': 2,
          'studentsWithFamily': 1,
        }),
      );

      final occupancy = await remote.fetchOccupancy();

      expect(occupancy.shifts.map((shift) => shift.shift), [
        OperationShift.morning,
      ]);
    });

    test(
      'reads whether the driver accepts students and the base price',
      () async {
        when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => okResponse(Map<String, dynamic>.of(driverMeJson)),
        );

        final attendance = await remote.fetchAttendance();

        expect(attendance.acceptingStudents, isTrue);
        expect(attendance.basePriceCents, 32050);
        verify(
          () => dio.get<Map<String, dynamic>>(
            'http://10.0.2.2:8080/api/drivers/me',
          ),
        ).called(1);
      },
    );

    test('a driver without a base price has none', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(<String, dynamic>{
          ...driverMeJson,
          'available': false,
          'basePrice': null,
        }),
      );

      final attendance = await remote.fetchAttendance();

      expect(attendance.acceptingStudents, isFalse);
      expect(attendance.basePriceCents, isNull);
    });

    test('replaces the availability with a full body', () async {
      when(
        () => dio.put<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async =>
            okResponse(<String, dynamic>{...driverMeJson, 'available': false}),
      );

      final attendance = await remote.updateAvailability(available: false);

      expect(attendance.acceptingStudents, isFalse);
      verify(
        () => dio.put<Map<String, dynamic>>(
          'http://10.0.2.2:8080/api/drivers/me/availability',
          data: {'available': false},
        ),
      ).called(1);
    });

    test('lists the assistants of the driver', () async {
      when(() => dio.get<List<dynamic>>(any())).thenAnswer(
        (_) async => okResponse<List<dynamic>>([
          Map<String, dynamic>.of(activeAssistantJson),
          Map<String, dynamic>.of(pendingAssistantJson),
          'not-an-object',
        ]),
      );

      final assistants = await remote.fetchAssistants();

      expect(assistants.map((assistant) => assistant.name), [
        'Marcos Lima',
        'Rita Souza',
      ]);
      expect(assistants.map((assistant) => assistant.status), [
        VanAssistantStatus.active,
        VanAssistantStatus.pending,
      ]);
      verify(
        () => dio.get<List<dynamic>>('http://10.0.2.2:8080/api/assistants'),
      ).called(1);
    });
  });

  group('VanCentralRepositoryImpl', () {
    late MockVanCentralRemoteDataSource remote;
    late VanCentralRepositoryImpl repository;

    setUp(() {
      remote = MockVanCentralRemoteDataSource();
      repository = VanCentralRepositoryImpl(remote: remote);
    });

    test('returns the occupancy it read', () async {
      when(() => remote.fetchOccupancy()).thenAnswer((_) async => occupancyDto);

      final result = await repository.findOccupancy();

      expect(result.valueOrNull, occupancyDto);
    });

    test('no response is a network failure', () async {
      when(() => remote.fetchAttendance()).thenThrow(statusError(null));

      final result = await repository.findAttendance();

      expect(result.errorOrNull, VanCentralFailure.network);
    });

    test('a server error is an unexpected failure', () async {
      when(() => remote.updateAvailability(available: true))
          .thenThrow(statusError(500));

      final result = await repository.changeAcceptingStudents(true);

      expect(result.errorOrNull, VanCentralFailure.unexpected);
    });

    test('a forbidden list of assistants is an unexpected failure', () async {
      when(() => remote.fetchAssistants()).thenThrow(statusError(403));

      final result = await repository.listAssistants();

      expect(result.errorOrNull, VanCentralFailure.unexpected);
    });

    test('returns the attendance after changing it', () async {
      when(() => remote.updateAvailability(available: true))
          .thenAnswer((_) async => attendanceDto);

      final result = await repository.changeAcceptingStudents(true);

      expect(result.valueOrNull, attendanceDto);
    });
  });
}
