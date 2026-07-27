import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/data/datasources/profile_summary_remote_datasource.dart';
import 'package:vanep_mobile/modules/profile/data/repositories/profile_summary_repository_impl.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';

import '../../profile_fixtures.dart';

class MockProfileSummaryRemoteDataSource extends Mock
    implements ProfileSummaryRemoteDataSource {}

void main() {
  late MockProfileSummaryRemoteDataSource remote;
  late ProfileSummaryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(UserType.client);
  });

  setUp(() {
    remote = MockProfileSummaryRemoteDataSource();
    repository = ProfileSummaryRepositoryImpl(remote: remote);
  });

  test('fetchSummary returns Ok with summary', () async {
    when(
      () => remote.fetchSummary(UserType.client),
    ).thenAnswer((_) async => testProfileSummaryDto);

    final result = await repository.fetchSummary(UserType.client);

    expect(result, isA<Ok>());
    expect(result.valueOrNull, testProfileSummaryDto);
  });

  test('fetchSummary maps DioException to NetworkProfileSummaryFailure', () async {
    when(() => remote.fetchSummary(UserType.driver)).thenThrow(
      DioException(requestOptions: RequestOptions(), message: 'offline'),
    );

    final result = await repository.fetchSummary(UserType.driver);

    expect(result, isA<Err>());
    expect(result.errorOrNull, const NetworkProfileSummaryFailure('offline'));
  });

  test('fetchSummary returns UnsupportedProfileSummaryFailure for ADMIN', () async {
    final result = await repository.fetchSummary(UserType.admin);

    expect(result.errorOrNull, const UnsupportedProfileSummaryFailure());
    verifyNever(() => remote.fetchSummary(any()));
  });
}
