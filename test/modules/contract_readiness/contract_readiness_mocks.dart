import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/datasources/contract_readiness_remote_datasource.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/repositories/contract_readiness_repository.dart';

class MockDio extends Mock implements Dio {}

class MockContractReadinessRemoteDataSource extends Mock
    implements ContractReadinessRemoteDataSource {}

class MockContractReadinessRepository extends Mock
    implements ContractReadinessRepository {}

const testReadinessEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

const readinessJson = <String, Object?>{
  'ready': false,
  'missing': [
    {'subject': 'CLIENT', 'field': 'PHONE'},
    {'subject': 'DEPENDENT', 'dependentToken': 'dep-pedro', 'field': 'SCHOOL'},
  ],
};

DioException readinessDioFailure(int? status) {
  final requestOptions = RequestOptions(
    path: '/api/clients/me/contract-readiness',
  );
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(requestOptions: requestOptions, statusCode: status),
  );
}
