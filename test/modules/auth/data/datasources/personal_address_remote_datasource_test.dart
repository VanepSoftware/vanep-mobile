import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/personal_address_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/personal_address_dto.dart';

import '../../personal_address_fixture.dart';
import '../auth_data_mocks.dart';

Response<Map<String, dynamic>> okAddress(Map<String, Object?> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: Map<String, dynamic>.from(body),
    );

void main() {
  late MockDio dio;
  late PersonalAddressRemoteDataSource remote;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = MockDio();
    remote = PersonalAddressRemoteDataSource(
      dio: dio,
      environment: testEnvironment,
    );
  });

  test('fetchMyAddress gets /api/user/me/address', () async {
    when(
      () => dio.get<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => okAddress(fakePersonalAddressJson()));

    final dto = await remote.fetchMyAddress();

    expect(personalAddressFromDto(dto), fakePersonalAddress());
    verify(
      () => dio.get<Map<String, dynamic>>(
        testEnvironment.userPersonalAddressEndpoint,
      ),
    ).called(1);
  });

  test('upsertMyAddress puts postal keys and maps the response', () async {
    final write = fakePersonalAddressWrite(
      number: '10',
      complement: 'Casa 2',
      neighborhood: 'Taguatinga',
    );
    when(
      () => dio.put<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => okAddress(fakePersonalAddressJson(street: 'SQN 108')),
    );

    final dto = await remote.upsertMyAddress(write);

    expect(personalAddressFromDto(dto), fakePersonalAddress(street: 'SQN 108'));
    verify(
      () => dio.put<Map<String, dynamic>>(
        testEnvironment.userPersonalAddressEndpoint,
        data: personalAddressUpsertBody(write),
      ),
    ).called(1);
  });

  test('deleteMyAddress deletes the endpoint without a body', () async {
    when(() => dio.delete<void>(any())).thenAnswer(
      (_) async =>
          Response<void>(requestOptions: RequestOptions(), statusCode: 204),
    );

    await remote.deleteMyAddress();

    verify(
      () => dio.delete<void>(testEnvironment.userPersonalAddressEndpoint),
    ).called(1);
  });
}
