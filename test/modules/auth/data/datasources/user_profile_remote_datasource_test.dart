import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/user_profile_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';

import '../auth_data_mocks.dart';

Response<Map<String, dynamic>> okBody(Map<String, dynamic> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: body,
    );

void main() {
  late MockDio dio;
  late UserProfileRemoteDataSource remote;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = MockDio();
    remote = UserProfileRemoteDataSource(
      dio: dio,
      environment: testEnvironment,
    );
  });

  test('fetchMe gets /api/user/me including cooldown fields', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => okBody({
        'token': 'user-token-1',
        'name': 'Ana',
        'email': 'ana@vanep.com.br',
        'gender': 'FEMALE',
        'type': 'DRIVER',
        'pendingEmail': 'novo@vanep.com.br',
        'nameChangeAvailableAt': '2026-09-01T12:00:00.000Z',
      }),
    );

    final profile = await remote.fetchMe();

    expect(profile.pendingEmail, 'novo@vanep.com.br');
    expect(
      profile.nameChangeAvailableAt,
      DateTime.parse('2026-09-01T12:00:00.000Z'),
    );
    expect(profile.gender, Gender.female);
    verify(
      () => dio.get<Map<String, dynamic>>(testEnvironment.userProfileEndpoint),
    ).called(1);
  });

  test('patchMe sends body map and returns profile', () async {
    when(
      () => dio.patch<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => okBody({
        'token': 'user-token-1',
        'name': 'Maria',
        'type': 'DRIVER',
      }),
    );

    final profile = await remote.patchMe({'name': 'Maria'});

    expect(profile.name, 'Maria');
    verify(
      () => dio.patch<Map<String, dynamic>>(
        testEnvironment.userProfileEndpoint,
        data: {'name': 'Maria'},
      ),
    ).called(1);
  });

  test('requestEmailChange posts to email-change endpoint', () async {
    when(
      () => dio.post<void>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<void>(
        requestOptions: RequestOptions(),
        statusCode: 204,
      ),
    );

    await remote.requestEmailChange('novo@vanep.com.br');

    verify(
      () => dio.post<void>(
        testEnvironment.userProfileEmailChangeEndpoint,
        data: {'email': 'novo@vanep.com.br'},
      ),
    ).called(1);
  });
}
