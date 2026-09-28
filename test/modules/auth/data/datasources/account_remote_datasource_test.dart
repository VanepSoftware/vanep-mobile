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
      'password': 'Secret@1',
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

  test('signUp omits the gender when the person prefers not to say', () async {
    await remote.signUp(validClientSignupForm.copyWith(clearGender: true));

    final body = capturedBody('http://10.0.2.2:8080/api/auth/signup/client');
    expect(body.containsKey('gender'), isFalse);
  });

  test('verifyEmail posts the e-mail and the code', () async {
    await remote.verifyEmail(email: 'ana@vanep.com.br', code: '012345');

    expect(capturedBody('http://10.0.2.2:8080/api/auth/email/verify'), {
      'email': 'ana@vanep.com.br',
      'code': '012345',
    });
  });

  test('resendEmailVerification posts the e-mail', () async {
    await remote.resendEmailVerification('ana@vanep.com.br');

    expect(capturedBody('http://10.0.2.2:8080/api/auth/email/verify/resend'), {
      'email': 'ana@vanep.com.br',
    });
  });

  test(
    'completeGoogleSignup posts the ticket, the type and the profile',
    () async {
      await remote.completeGoogleSignup(
        ticket: 'ticket-1',
        form: validDriverSignupForm,
      );

      final body = capturedBody(
        'http://10.0.2.2:8080/api/auth/signup/complete',
      );
      expect(body['signupTicket'], 'ticket-1');
      expect(body['type'], 'DRIVER');
      expect(body['document'], '52998224725');
      expect(body['basePrice'], 1250.5);
      expect(body.containsKey('password'), isFalse);
      expect(body.containsKey('email'), isFalse);
    },
  );

  test('requestPasswordReset posts the e-mail', () async {
    await remote.requestPasswordReset('ana@vanep.com.br');

    expect(capturedBody('http://10.0.2.2:8080/api/auth/password/forgot'), {
      'email': 'ana@vanep.com.br',
    });
  });

  test('resetPassword posts e-mail, code and new password', () async {
    await remote.resetPassword(
      email: 'ana@vanep.com.br',
      code: '123456',
      newPassword: 'nova-senha',
    );

    expect(capturedBody('http://10.0.2.2:8080/api/auth/password/reset'), {
      'email': 'ana@vanep.com.br',
      'code': '123456',
      'newPassword': 'nova-senha',
    });
  });
}
