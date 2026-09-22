import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_lean_signup_request_dto.dart';

class MockDio extends Mock implements Dio {}

const testEnvironment = Environment(
  authBaseUrl: 'https://api.vanep.test',
  oauthClientId: 'vanep-mobile',
);

Response<T> _response<T>(T? data, {int statusCode = 200}) => Response<T>(
      requestOptions: RequestOptions(path: ''),
      statusCode: statusCode,
      data: data,
    );

void main() {
  late MockDio dio;
  late AssistantRemoteDataSourceImpl datasource;

  setUp(() {
    dio = MockDio();
    datasource = AssistantRemoteDataSourceImpl(
      dio: dio,
      environment: testEnvironment,
    );
  });

  group('validateInvite', () {
    test('fetches invite by code query parameter', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _response<Map<String, dynamic>>({
          'token': 'inv-123',
          'driverName': 'Pedro',
          'status': 'PENDING',
        }),
      );

      final invite = await datasource.validateInvite('CODE-99');

      expect(invite.token, 'inv-123');
      expect(invite.driverName, 'Pedro');
      verify(
        () => dio.get<Map<String, dynamic>>(
          'https://api.vanep.test/api/assistants/me/invite',
          queryParameters: {'code': 'CODE-99'},
        ),
      ).called(1);
    });

    test('throws FormatException when response data is null', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response<Map<String, dynamic>>(null));

      expect(
        () => datasource.validateInvite('CODE-99'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('registerWithInvite', () {
    test('posts lean signup payload to signup assistant endpoint', () async {
      when(
        () => dio.post<void>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _response<void>(null));

      const request = AssistantLeanSignupRequestDto(
        inviteToken: 'inv-tok',
        name: 'Carlos',
        birthDate: '1998-05-20',
        email: 'carlos@vanep.test',
        cpf: '123.456.789-00',
      );

      await datasource.registerWithInvite(request);

      verify(
        () => dio.post<void>(
          'https://api.vanep.test/api/auth/signup/assistant',
          data: request.toJson(),
        ),
      ).called(1);
    });
  });

  group('fetchLinkedVans', () {
    test('returns list of vans when API returns a non-empty list', () async {
      when(
        () => dio.get<List<dynamic>>(any()),
      ).thenAnswer(
        (_) async => _response<List<dynamic>>([
          {
            'token': 'van-1',
            'driverToken': 'drv-1',
            'driverName': 'Pedro',
            'plate': 'ABC-1234',
            'model': 'Sprinter',
          }
        ]),
      );

      final vans = await datasource.fetchLinkedVans();

      expect(vans, hasLength(1));
      expect(vans.first.plate, 'ABC-1234');
      verify(
        () => dio.get<List<dynamic>>(
          'https://api.vanep.test/api/assistants/me/vans',
        ),
      ).called(1);
    });

    test('returns empty list when response data is null', () async {
      when(
        () => dio.get<List<dynamic>>(any()),
      ).thenAnswer((_) async => _response<List<dynamic>>(null));

      final vans = await datasource.fetchLinkedVans();

      expect(vans, isEmpty);
    });
  });

  group('acceptInvite and rejectInvite', () {
    test('posts to accept endpoint', () async {
      when(
        () => dio.post<void>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _response<void>(null));

      await datasource.acceptInvite('inv-tok');

      verify(
        () => dio.post<void>(
          'https://api.vanep.test/api/assistants/me/invite/accept',
          data: {'token': 'inv-tok'},
        ),
      ).called(1);
    });

    test('posts to reject endpoint', () async {
      when(
        () => dio.post<void>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _response<void>(null));

      await datasource.rejectInvite('inv-tok');

      verify(
        () => dio.post<void>(
          'https://api.vanep.test/api/assistants/me/invite/reject',
          data: {'token': 'inv-tok'},
        ),
      ).called(1);
    });
  });
}
