import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_invite_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

import '../../fixtures/assistant_fixtures.dart';

class MockAssistantRemoteDataSource extends Mock
    implements AssistantRemoteDataSource {}

void main() {
  late MockAssistantRemoteDataSource remote;
  late AssistantVansRepositoryImpl repository;

  final apiInvite = AssistantInviteDto(
    token: 'inv-real',
    driverName: 'Ana Ribeiro',
    expiresAt: DateTime.utc(2026, 12, 1),
    status: 'PENDING',
  );

  setUp(() {
    remote = MockAssistantRemoteDataSource();
    repository = AssistantVansRepositoryImpl(remote: remote);
    when(() => remote.fetchVanSummaries())
        .thenAnswer((_) async => testAssistantVansOverview.activeVans);
    when(() => remote.fetchFormerLinkCount()).thenAnswer((_) async => 2);
  });

  test(
    'joins the invite, the vans and the former links from the API',
    () async {
      when(() => remote.fetchPendingInvite())
          .thenAnswer((_) async => apiInvite);

      final overview = (await repository.findVansOverview()).valueOrNull!;

      expect(overview.pendingInvite, apiInvite);
      expect(overview.activeVans, testAssistantVansOverview.activeVans);
      expect(overview.formerVanCount, 2);
    },
  );

  test('has no pending invite when the API has none', () async {
    when(() => remote.fetchPendingInvite()).thenAnswer((_) async => null);

    final overview = (await repository.findVansOverview()).valueOrNull!;

    expect(overview.pendingInvite, isNull);
  });

  test('fails when one of the requests fails', () async {
    when(() => remote.fetchPendingInvite()).thenAnswer((_) async => null);
    when(() => remote.fetchVanSummaries())
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    final result = await repository.findVansOverview();

    expect(result.errorOrNull, AssistantFailure.network);
  });
}
