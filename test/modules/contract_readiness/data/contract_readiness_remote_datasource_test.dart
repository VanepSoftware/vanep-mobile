import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/datasources/contract_readiness_remote_datasource.dart';

import '../contract_readiness_mocks.dart';

void main() {
  late MockDio dio;
  late ContractReadinessRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = ContractReadinessRemoteDataSource(
      dio: dio,
      environment: testReadinessEnvironment,
    );
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: Map<String, dynamic>.of(readinessJson),
      ),
    );
  });

  test(
    'findReadiness sends each dependent token as a repeated query',
    () async {
      final readiness = await remote.findReadiness(['dep-pedro', 'dep-ana']);

      expect(readiness.ready, isFalse);
      final query =
          verify(
                () => dio.get<Map<String, dynamic>>(
                  testReadinessEnvironment.contractReadinessEndpoint,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      final uri = RequestOptions(
        path: testReadinessEnvironment.contractReadinessEndpoint,
        queryParameters: query,
      ).uri;
      expect(
        uri.toString(),
        'http://10.0.2.2:8080/api/clients/me/contract-readiness'
        '?dependentTokens=dep-pedro&dependentTokens=dep-ana',
      );
    },
  );
}
