import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_invite_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

class MockAssistantRemoteDataSource extends Mock
    implements AssistantRemoteDataSource {}

void main() {
  late MockAssistantRemoteDataSource remote;
  late MockAssistantVansDataSource dataSource;
  late AssistantVansRepositoryImpl repository;

  final apiInvite = AssistantInviteDto(
    token: 'inv-real',
    driverName: 'Ana Ribeiro',
    expiresAt: DateTime.utc(2026, 12, 1),
    status: 'PENDING',
  );

  setUp(() {
    remote = MockAssistantRemoteDataSource();
    dataSource = MockAssistantVansDataSource();
    repository = AssistantVansRepositoryImpl(
      remote: remote,
      dataSource: dataSource,
    );
    when(
      () => dataSource.findVansOverview(),
    ).thenAnswer((_) async => testAssistantVansOverview);
  });

  test('takes the pending invite from the API and the vans from the '
      'data source', () async {
    when(() => remote.fetchPendingInvite()).thenAnswer((_) async => apiInvite);

    final overview = (await repository.findVansOverview()).valueOrNull!;

    expect(overview.pendingInvite, apiInvite);
    expect(overview.activeVans, testAssistantVansOverview.activeVans);
    expect(overview.formerVanCount, testAssistantVansOverview.formerVanCount);
  });

  test('has no pending invite when the API has none', () async {
    when(() => remote.fetchPendingInvite()).thenAnswer((_) async => null);

    final overview = (await repository.findVansOverview()).valueOrNull!;

    expect(overview.pendingInvite, isNull);
  });

  test('fails when the invite request fails', () async {
    when(() => remote.fetchPendingInvite()).thenThrow(
      DioException(requestOptions: RequestOptions(path: '')),
    );

    final result = await repository.findVansOverview();

    expect(result.errorOrNull, AssistantFailure.network);
  });
}
