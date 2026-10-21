import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

import '../dependents_mocks.dart';

const schoolDaysUrl =
    'http://10.0.2.2:8080/api/dependent/dep-pedro/school-days';

Response<T> okResponse<T>(T? body, {int status = 200}) {
  return Response<T>(
    requestOptions: RequestOptions(),
    statusCode: status,
    data: body,
  );
}

void main() {
  late MockDio dio;
  late DependentRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = DependentRemoteDataSource(
      dio: dio,
      environment: testDependentsEnvironment,
    );
  });

  test('fetchSchoolDays gets the school-days of the dependent', () async {
    when(() => dio.get<List<dynamic>>(any())).thenAnswer(
      (_) async => okResponse<List<dynamic>>([
        {'weekday': 'TUESDAY', 'schoolShift': 'MORNING'},
      ]),
    );

    final week = await remote.fetchSchoolDays('dep-pedro');

    expect(week.shiftOf(Weekday.tuesday), SchoolShift.morning);
    verify(() => dio.get<List<dynamic>>(schoolDaysUrl)).called(1);
  });

  test('replaceSchoolDays puts the whole week and reads the answer', () async {
    when(() => dio.put<List<dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer(
          (_) async => okResponse<List<dynamic>>([
            {'weekday': 'MONDAY', 'schoolShift': 'NIGHT'},
          ]),
        );

    final saved = await remote.replaceSchoolDays(
      token: 'dep-pedro',
      week: const SchoolWeek.empty().turnOn(Weekday.monday),
    );

    expect(saved.shiftOf(Weekday.monday), SchoolShift.night);
    final body =
        verify(
              () => dio.put<List<dynamic>>(
                schoolDaysUrl,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(body, {
      'days': [
        {'weekday': 'MONDAY', 'schoolShift': 'MORNING'},
      ],
    });
  });

  test('removeDependent deletes the dependent by its token', () async {
    when(() => dio.delete<void>(any()))
        .thenAnswer((_) async => okResponse<void>(null, status: 204));

    await remote.removeDependent('dep-pedro');

    verify(
      () => dio.delete<void>('http://10.0.2.2:8080/api/dependent/dep-pedro'),
    ).called(1);
  });
}
