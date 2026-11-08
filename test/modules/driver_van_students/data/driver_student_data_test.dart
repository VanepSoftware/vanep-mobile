import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/datasources/driver_student_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/dtos/driver_student_dto.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/dtos/unlinked_passenger_request_body.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/repositories/driver_student_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_source.dart';

import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

const environment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

const passengersUrl = 'http://10.0.2.2:8080/api/drivers/me/unlinked-passengers';

Response<T> okResponse<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(), data: data);

DioException statusError(int? status, {Object? body}) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<Object?>(
          requestOptions: RequestOptions(),
          statusCode: status,
          data: body,
        ),
);

void main() {
  setUpAll(() => registerFallbackValue(FakeUnlinkedPassengerDraft()));
  group('DriverStudentDto', () {
    test('reads an unlinked student with a pending family match', () {
      final student = DriverStudentDto.fromJson(studentJson);

      expect(student.source, StudentSource.unlinkedPassenger);
      expect(student.familyStatus, FamilyStatus.familyJoined);
      expect(student.schoolShift, SchoolShift.morning);
      expect(student.slots.single.leg, RouteLeg.outbound);
      expect(student.invitedAt, DateTime.utc(2026, 11, 1, 12));
      expect(student.familyMatch?.dependentName, 'Rafael Costa');
      expect(student.familyMatch?.dependentAge, 9);
    });

    test('reads a contracted student without school shift or match', () {
      final student = DriverStudentDto.fromJson(contractStudentJson);

      expect(student.source, StudentSource.contractItem);
      expect(student.familyStatus, FamilyStatus.withFamily);
      expect(student.schoolShift, isNull);
      expect(student.familyMatch, isNull);
      expect(student.dependentToken, 'dep-bruno');
    });

    test('an unknown family status is unreadable', () {
      expect(
        () => DriverStudentDto.fromJson({
          ...studentJson,
          'familyStatus': 'SOMETHING',
        }),
        throwsFormatException,
      );
    });
  });

  test('the create body carries trimmed fields, slots and the van', () {
    final body = unlinkedPassengerDraftToJson(completeDraft());

    expect(body['name'], 'Laura Mendes');
    expect(body['schoolToken'], 'school-1');
    expect(body['schoolShift'], 'MORNING');
    expect(body['notes'], isNull);
    expect(body['vehicleToken'], 'van-1');
    expect(body['address'], containsPair('zipCode', '01001000'));
    expect(body['slots'], [
      {
        'weekday': 'MONDAY',
        'leg': 'OUTBOUND',
        'shift': 'MORNING',
        'pickupTime': '06:40',
      },
      {
        'weekday': 'MONDAY',
        'leg': 'RETURN',
        'shift': 'MORNING',
        'pickupTime': '12:10',
      },
    ]);
  });

  group('DriverStudentRemoteDataSource', () {
    late MockDio dio;
    late DriverStudentRemoteDataSource remote;

    setUp(() {
      dio = MockDio();
      remote = DriverStudentRemoteDataSource(
        dio: dio,
        environment: environment,
      );
    });

    test('lists the students of a van', () async {
      when(
        () => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => okResponse(<dynamic>[studentJson]));

      final students = await remote.listStudents(vehicleToken: 'van-1');

      expect(students.single.token, 'student-rafael');
      verify(
        () => dio.get<List<dynamic>>(
          'http://10.0.2.2:8080/api/drivers/me/students',
          queryParameters: {'vehicleToken': 'van-1'},
        ),
      ).called(1);
    });

    test('lists every student without a van', () async {
      when(
        () => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => okResponse(<dynamic>[]));

      await remote.listStudents();

      verify(
        () =>
            dio.get<List<dynamic>>(any(), queryParameters: <String, dynamic>{}),
      ).called(1);
    });

    test('invites, merges and dismisses on the passenger paths', () async {
      when(() => dio.post<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(Map<String, dynamic>.of(inviteJson)),
      );

      final invite = await remote.inviteFamily('rafa');
      await remote.mergeFamily('rafa');
      await remote.dismissFamilyMatch('rafa');

      expect(invite.inviteUrl, 'https://vanep.com.br/convite/ABCD2345EFGH');
      verify(
        () => dio.post<Map<String, dynamic>>('$passengersUrl/rafa/invite'),
      );
      verify(() => dio.post<Map<String, dynamic>>('$passengersUrl/rafa/merge'));
      verify(
        () => dio.post<Map<String, dynamic>>(
          '$passengersUrl/rafa/family-match/dismiss',
        ),
      );
    });

    test('reads the parents group link', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(Map<String, dynamic>.of(inviteJson)),
      );

      final invite = await remote.findParentsGroupInvite();

      expect(invite.code, 'ABCD2345EFGH');
      verify(
        () => dio.get<Map<String, dynamic>>(
          'http://10.0.2.2:8080/api/drivers/me/invite-link',
        ),
      ).called(1);
    });

    test('creates an unlinked passenger and answers its token', () async {
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse(<String, dynamic>{'token': 'new'}));

      final token = await remote.createUnlinkedPassenger(completeDraft());

      expect(token, 'new');
      verify(
        () => dio.post<Map<String, dynamic>>(
          passengersUrl,
          data: unlinkedPassengerDraftToJson(completeDraft()),
        ),
      ).called(1);
    });
  });

  group('DriverStudentRepositoryImpl', () {
    late MockDriverStudentRemoteDataSource remote;
    late DriverStudentRepositoryImpl repository;

    setUp(() {
      remote = MockDriverStudentRemoteDataSource();
      repository = DriverStudentRepositoryImpl(remote: remote);
    });

    test('answers the students', () async {
      when(() => remote.listStudents(vehicleToken: 'van-1'))
          .thenAnswer((_) async => [uninvitedLaura]);

      final result = await repository.listStudents(vehicleToken: 'van-1');

      expect(result.valueOrNull, [uninvitedLaura]);
    });

    test('maps HTTP errors to failures', () async {
      final cases = <DioException, DriverStudentFailure>{
        statusError(null): const DriverStudentNetworkFailure(),
        statusError(404): const DriverStudentNotFoundFailure(),
        statusError(400, body: {'detail': 'Dados inválidos.'}):
            const DriverStudentRejectedFailure(detail: 'Dados inválidos.'),
        statusError(409, body: {'detail': 'Já juntado.'}):
            const DriverStudentRejectedFailure(detail: 'Já juntado.'),
        statusError(422, body: {'detail': 'Van inválida.'}):
            const DriverStudentRejectedFailure(detail: 'Van inválida.'),
        statusError(500): const DriverStudentUnexpectedFailure(),
        statusError(409): const DriverStudentUnexpectedFailure(),
      };
      for (final MapEntry(key: error, value: failure) in cases.entries) {
        when(() => remote.mergeFamily('rafa')).thenThrow(error);

        expect(
          await repository.mergeFamily('rafa'),
          Err<DriverStudentFailure, void>(failure),
        );
      }
    });

    test('a rejected registration preserves HTTP 400 detail', () async {
      when(() => remote.createUnlinkedPassenger(any()))
          .thenThrow(statusError(400, body: {'detail': 'Escola inválida.'}));
      expect(
        (await repository.createUnlinkedPassenger(completeDraft())).errorOrNull,
        const DriverStudentRejectedFailure(detail: 'Escola inválida.'),
      );
    });

    test('an unreadable body is an unexpected failure', () async {
      when(() => remote.findParentsGroupInvite())
          .thenThrow(const FormatException('bad'));

      expect(
        (await repository.findParentsGroupInvite()).errorOrNull,
        const DriverStudentUnexpectedFailure(),
      );
    });
  });
}
