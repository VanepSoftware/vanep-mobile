import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/data/repositories/client_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';

import '../fixtures/client_vans_fixture.dart';

class _MockClientVansDataSource extends Mock implements ClientVansDataSource {}

DioException _dioError(int? statusCode) {
  final options = RequestOptions(path: '/api/client-drivers/me');
  return DioException(
    requestOptions: options,
    response: statusCode == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  late _MockClientVansDataSource dataSource;
  late ClientVansRepositoryImpl repository;

  setUp(() {
    dataSource = _MockClientVansDataSource();
    repository = ClientVansRepositoryImpl(dataSource: dataSource);
  });

  test('returns vans from remote datasource', () async {
    when(dataSource.fetchMyVans).thenAnswer((_) async => [testClientVan]);

    final result = await repository.findMyVans();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, [testClientVan]);
  });

  test('returns empty list without falling back to mocked data', () async {
    when(dataSource.fetchMyVans).thenAnswer((_) async => const []);

    final result = await repository.findMyVans();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isEmpty);
  });

  test('maps 401 and 403 responses to unauthenticated failure', () async {
    when(dataSource.fetchMyVans).thenThrow(_dioError(403));

    final result = await repository.findMyVans();

    expect(result.errorOrNull, ClientVansFailure.unauthenticated);
  });

  test('maps network dio errors to network failure', () async {
    when(dataSource.fetchMyVans).thenThrow(_dioError(500));

    final result = await repository.findMyVans();

    expect(result.errorOrNull, ClientVansFailure.network);
  });

  test('maps unexpected errors to unexpected failure', () async {
    when(dataSource.fetchMyVans).thenThrow(const FormatException('bad'));

    final result = await repository.findMyVans();

    expect(result.errorOrNull, ClientVansFailure.unexpected);
  });
}
