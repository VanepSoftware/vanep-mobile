import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/data/datasources/profile_summary_remote_datasource.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';

import '../../profile_fixtures.dart';

class MockDio extends Mock implements Dio {}

const testEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
);

void main() {
  late MockDio dio;
  late ProfileSummaryRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = ProfileSummaryRemoteDataSource(
      dio: dio,
      environment: testEnvironment,
    );
  });

  test('fetchSummary returns ClientProfileSummary for CLIENT', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {
          'token': 'client-summary-1',
          'photo': 'https://cdn.example.com/photo.jpg',
          'rating': 4.5,
          'active': true,
          'user': {
            'token': 'user-token-1',
            'name': 'Alex',
            'type': 'CLIENT',
          },
        },
      ),
    );

    final summary = await remote.fetchSummary(UserType.client);

    expect(summary, testClientSummaryDto);
    expect(summary, isA<ClientProfileSummary>());
    verify(
      () => dio.get<Map<String, dynamic>>(testEnvironment.clientsMeEndpoint),
    ).called(1);
  });

  test('fetchSummary returns DriverProfileSummary for DRIVER', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {
          'token': 'summary-token-1',
          'photo': 'https://cdn.example.com/photo.jpg',
          'rating': 4.8,
          'city': 'São Paulo',
          'approvalStatus': 'APPROVED',
          'available': true,
          'active': true,
          'user': {
            'token': 'user-token-1',
            'name': 'Ana Motorista',
            'email': 'ana@vanep.com.br',
            'type': 'DRIVER',
          },
        },
      ),
    );

    final summary = await remote.fetchSummary(UserType.driver);

    expect(summary, testDriverSummaryDto);
    expect(summary, isA<DriverProfileSummary>());
    verify(
      () => dio.get<Map<String, dynamic>>(testEnvironment.driversMeEndpoint),
    ).called(1);
  });

  test('fetchSummary returns AssistantProfileSummary for ASSISTANT', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {
          'token': 'assistant-summary-1',
          'photo': 'https://cdn.example.com/photo.jpg',
          'status': 'ACTIVE',
        },
      ),
    );

    final summary = await remote.fetchSummary(UserType.assistant);

    expect(summary, isA<AssistantProfileSummary>());
    expect(
      (summary as AssistantProfileSummary).status,
      AssistantStatus.active,
    );
    verify(
      () =>
          dio.get<Map<String, dynamic>>(testEnvironment.assistantsMeEndpoint),
    ).called(1);
  });

  test('profileSummaryEndpointFor maps user types', () {
    expect(
      profileSummaryEndpointFor(UserType.client, testEnvironment),
      'http://10.0.2.2:8080/api/clients/me',
    );
    expect(
      profileSummaryEndpointFor(UserType.driver, testEnvironment),
      'http://10.0.2.2:8080/api/drivers/me',
    );
    expect(
      profileSummaryEndpointFor(UserType.assistant, testEnvironment),
      'http://10.0.2.2:8080/api/assistants/me',
    );
  });
}
