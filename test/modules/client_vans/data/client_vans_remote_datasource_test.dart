import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_remote_datasource.dart';

class _MockDio extends Mock implements Dio {}

const _testEnv = Environment(
  authBaseUrl: 'https://api.example.com',
  oauthClientId: 'test-client',
);

Response<T> _ok<T>(String path, T data) {
  return Response<T>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

void main() {
  late _MockDio dio;
  late ClientVansRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = ClientVansRemoteDataSource(dio: dio, environment: _testEnv);
  });

  test('hides PENDING links whose proposal or request was cancelled', () async {
    when(() => dio.get<List<dynamic>>(_testEnv.clientDriversMeEndpoint))
        .thenAnswer(
      (_) async => _ok(_testEnv.clientDriversMeEndpoint, [
        {
          'token': 'link-active',
          'driverToken': 'drv-active',
          'driverName': 'Carlos Active',
          'status': 'ACTIVE',
        },
        {
          'token': 'link-open',
          'driverToken': 'drv-open',
          'driverName': 'Maria Open',
          'status': 'PENDING',
        },
        {
          'token': 'link-cancelled',
          'driverToken': 'drv-cancelled',
          'driverName': 'Pedro Cancelled',
          'status': 'PENDING',
        },
      ]),
    );

    when(
      () => dio.get<Map<String, dynamic>>(
        _testEnv.clientServiceRequestsEndpoint,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _ok(_testEnv.clientServiceRequestsEndpoint, {
        'content': [
          {
            'token': 'req-open',
            'clientDriverToken': 'link-open',
            'driverToken': 'drv-open',
            'status': 'OPEN',
          },
        ],
      }),
    );

    for (final linkToken in ['link-active', 'link-open', 'link-cancelled']) {
      when(
        () => dio.get<List<dynamic>>(
          _testEnv.clientDriverContractsEndpoint(linkToken),
        ),
      ).thenAnswer(
        (_) async => _ok(_testEnv.clientDriverContractsEndpoint(linkToken), []),
      );
    }

    for (final drvToken in ['drv-active', 'drv-open']) {
      when(
        () => dio.get<Map<String, dynamic>>(
          _testEnv.driverProfileEndpoint(drvToken),
        ),
      ).thenAnswer(
        (_) async => _ok(_testEnv.driverProfileEndpoint(drvToken), {
          'phone': '11999990000',
          'rating': 4.8,
          'vehicles': [],
        }),
      );
    }

    final vans = await dataSource.fetchMyVans();

    expect(vans.map((v) => v.token), ['link-active', 'link-open']);
    verifyNever(
      () => dio.get<Map<String, dynamic>>(
        _testEnv.driverProfileEndpoint('drv-cancelled'),
      ),
    );
  });

  test('keeps PENDING link when it has an in-progress contract', () async {
    when(() => dio.get<List<dynamic>>(_testEnv.clientDriversMeEndpoint))
        .thenAnswer(
      (_) async => _ok(_testEnv.clientDriversMeEndpoint, [
        {
          'token': 'link-contract',
          'driverToken': 'drv-contract',
          'driverName': 'Ana Contract',
          'status': 'PENDING',
        },
      ]),
    );

    when(
      () => dio.get<Map<String, dynamic>>(
        _testEnv.clientServiceRequestsEndpoint,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _ok(_testEnv.clientServiceRequestsEndpoint, {
        'content': <Object?>[],
      }),
    );

    when(
      () => dio.get<List<dynamic>>(
        _testEnv.clientDriverContractsEndpoint('link-contract'),
      ),
    ).thenAnswer(
      (_) async => _ok(_testEnv.clientDriverContractsEndpoint('link-contract'), [
        {
          'token': 'ctr-1',
          'status': 'AWAITING_SIGNATURES',
          'startsOn': '2026-02-01',
          'endsOn': '2026-12-20',
          'totalAmount': 3000,
          'installments': 10,
          'dueDay': 5,
          'items': <Object?>[],
        },
      ]),
    );

    when(
      () => dio.get<Map<String, dynamic>>(
        _testEnv.driverProfileEndpoint('drv-contract'),
      ),
    ).thenAnswer(
      (_) async => _ok(_testEnv.driverProfileEndpoint('drv-contract'), {
        'vehicles': [],
      }),
    );

    final vans = await dataSource.fetchMyVans();

    expect(vans.map((v) => v.token), ['link-contract']);
  });

  test('excludes INACTIVE link with no active contract', () async {
    when(() => dio.get<List<dynamic>>(_testEnv.clientDriversMeEndpoint))
        .thenAnswer(
      (_) async => _ok(_testEnv.clientDriversMeEndpoint, [
        {
          'token': 'link-inactive',
          'driverToken': 'drv-inactive',
          'driverName': 'Old Driver',
          'status': 'INACTIVE',
        },
      ]),
    );

    when(
      () => dio.get<List<dynamic>>(
        _testEnv.clientDriverContractsEndpoint('link-inactive'),
      ),
    ).thenAnswer(
      (_) async => _ok(_testEnv.clientDriverContractsEndpoint('link-inactive'), [
        {
          'token': 'ctr-old',
          'status': 'CANCELLED',
          'startsOn': '2025-02-01',
          'endsOn': '2025-12-20',
          'totalAmount': 2000,
          'installments': 10,
          'dueDay': 5,
          'items': <Object?>[],
        },
      ]),
    );

    final vans = await dataSource.fetchMyVans();

    expect(vans, isEmpty);
  });
}
