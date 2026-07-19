import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/data/repositories/driver_repository_impl.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';

import '../drivers_data_mocks.dart';
import '../../drivers_fixtures.dart';

void main() {
  late MockDriverRemoteDataSource remote;
  late DriverRepositoryImpl repository;

  setUp(() {
    remote = MockDriverRemoteDataSource();
    repository = DriverRepositoryImpl(remote: remote);
  });

  test('returns Ok with drivers on success', () async {
    when(
      () => remote.fetchRecentDrivers(limit: any(named: 'limit')),
    ).thenAnswer((_) async => testRecentDrivers);

    final result = await repository.fetchRecentDrivers(limit: 3);

    expect(result, isA<Ok<DriverFailure, dynamic>>());
    expect(result.valueOrNull, hasLength(2));
  });

  test('maps DioException to NetworkDriverFailure', () async {
    when(() => remote.fetchRecentDrivers(limit: any(named: 'limit'))).thenThrow(
      DioException(requestOptions: RequestOptions(), message: 'boom'),
    );

    final result = await repository.fetchRecentDrivers(limit: 3);

    expect(result.errorOrNull, isA<NetworkDriverFailure>());
  });

  test('maps unexpected errors to UnexpectedDriverFailure', () async {
    when(
      () => remote.fetchRecentDrivers(limit: any(named: 'limit')),
    ).thenThrow(StateError('unexpected'));

    final result = await repository.fetchRecentDrivers(limit: 3);

    expect(result.errorOrNull, isA<UnexpectedDriverFailure>());
  });
}
