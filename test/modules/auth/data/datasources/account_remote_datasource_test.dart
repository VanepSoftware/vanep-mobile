import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/account_remote_datasource.dart';

import '../../account_fixtures.dart';
import '../auth_data_mocks.dart';

void main() {
  late MockDio dio;
  late AccountRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = AccountRemoteDataSource(dio: dio, environment: testEnvironment);
    when(() => dio.post<void>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async =>
          Response<void>(requestOptions: RequestOptions(), statusCode: 201),
    );
  });

  Map<String, Object?> capturedBody(String endpoint) {
    return verify(
          () => dio.post<void>(endpoint, data: captureAny(named: 'data')),
        ).captured.single
        as Map<String, Object?>;
  }

  test('signUp posts a client form with normalized values', () async {
    await remote.signUp(validClientSignupForm);

    expect(capturedBody('http://10.0.2.2:8080/api/auth/signup/client'), {
      'name': 'Ana Cliente',
      'email': 'ana@vanep.com.br',
      'password': 'secret1',
      'document': '52998224725',
      'phone': '11999990000',
      'birthDate': '1990-05-15',
      'gender': 'FEMALE',
      'acceptTerms': true,
    });
  });

  test('signUp posts driver fields to the driver endpoint', () async {
    await remote.signUp(validDriverSignupForm);

    final body = capturedBody('http://10.0.2.2:8080/api/auth/signup/driver');
    expect(body['basePrice'], 1250.5);
    expect(body['cnpj'], '11222333000181');
    expect(body['experienceYears'], 7);
  });

  test('signUp omits optional fields left blank', () async {
    await remote.signUp(
      validClientSignupForm.copyWith(phone: '', clearBirthDate: true),
    );

    final body = capturedBody('http://10.0.2.2:8080/api/auth/signup/client');
    expect(body.containsKey('phone'), isFalse);
    expect(body.containsKey('birthDate'), isFalse);
  });
}
