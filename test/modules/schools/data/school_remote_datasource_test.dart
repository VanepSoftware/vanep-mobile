import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/schools/data/datasources/school_remote_datasource.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

import '../schools_mocks.dart';

void main() {
  late MockDio dio;
  late SchoolRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = SchoolRemoteDataSource(
      dio: dio,
      environment: testSchoolsEnvironment,
    );
  });

  void answerWith(int status) {
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(),
            statusCode: status,
            data: Map<String, dynamic>.of(deltaSchoolJson),
          ),
        );
  }

  test('resolveSchool posts the place and the session token', () async {
    answerWith(201);

    await remote.resolveSchool(placeId: 'place-delta', sessionToken: 'sess-1');

    verify(
      () => dio.post<Map<String, dynamic>>(
        'http://10.0.2.2:8080/api/schools/resolve',
        data: {'placeId': 'place-delta', 'sessionToken': 'sess-1'},
      ),
    ).called(1);
  });

  for (final status in [200, 201]) {
    test('a $status answer is the resolved school', () async {
      answerWith(status);

      final school = await remote.resolveSchool(
        placeId: 'place-delta',
        sessionToken: 'sess-1',
      );

      expect(
        school,
        const School(token: 'school-delta', name: 'Colégio Delta'),
      );
    });
  }
}
