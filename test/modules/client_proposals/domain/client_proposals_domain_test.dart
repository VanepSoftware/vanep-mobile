import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  group('ProposalsFeed', () {
    test('counts open as proposals to answer plus requests sent', () {
      expect(testProposalsFeed.openCount, 3);
      expect(testProposalsFeed.closedCount, 2);
    });

    test('without a child it keeps every entry', () {
      expect(testProposalsFeed.forChild(null), testProposalsFeed);
    });

    test('filters every list by child', () {
      final anaFeed = testProposalsFeed.forChild(testAna.token);

      expect(anaFeed.pending, isEmpty);
      expect(anaFeed.awaiting, isEmpty);
      expect(anaFeed.closed, [testFernandaClosed]);
    });
  });

  group('ClientProposals', () {
    test('filters by child only with more than one child', () {
      expect(testClientProposals().canFilterByChild, isTrue);
      expect(
        testClientProposals(children: const [testPedro]).canFilterByChild,
        isFalse,
      );
      expect(testClientProposals(children: const []).canFilterByChild, isFalse);
    });

    test('the open-request count is account-wide', () {
      final proposals = testClientProposals();

      expect(proposals.openRequestsCount, 3);
      expect(proposals.hasReachedOpenRequestsLimit, isFalse);
    });

    test('reaches the limit at five open requests', () {
      final proposals = testClientProposals(
        feed: ProposalsFeed(
          pending: [testJoaoPedroProposal, testRitaProposal, testAnaProposal],
          awaiting: [testMarcosRequest, testMarcosRequest],
        ),
      );

      expect(proposals.openRequestsCount, openRequestsLimit);
      expect(proposals.hasReachedOpenRequestsLimit, isTrue);
    });

    test('finds a child by token', () {
      final proposals = testClientProposals();

      expect(proposals.childWithToken(testAna.token), testAna);
      expect(proposals.childWithToken('unknown'), isNull);
      expect(proposals.childWithToken(null), isNull);
    });
  });

  group('LoadClientProposals', () {
    late MockClientProposalsRepository repository;
    late LoadClientProposals loadClientProposals;

    setUp(() {
      repository = MockClientProposalsRepository();
      loadClientProposals = LoadClientProposals(
        repository: repository,
        clock: () => testProposalsNow,
      );
    });

    test('joins children and proposals', () async {
      when(
        repository.findProposals,
      ).thenAnswer((_) async => Ok(testProposalsFeed));
      when(
        repository.findChildren,
      ).thenAnswer((_) async => const Ok([testPedro, testLucas, testAna]));

      final result = await loadClientProposals();

      expect(result, Ok<ClientProposalsFailure, ClientProposals>(
        testClientProposals(),
      ));
    });

    test('fails when proposals fail', () async {
      when(repository.findProposals).thenAnswer(
        (_) async => const Err(ClientProposalsFailure.unexpected),
      );
      when(
        repository.findChildren,
      ).thenAnswer((_) async => const Ok([testPedro]));

      final result = await loadClientProposals();

      expect(result.errorOrNull, ClientProposalsFailure.unexpected);
    });

    test('fails when children fail', () async {
      when(
        repository.findProposals,
      ).thenAnswer((_) async => Ok(testProposalsFeed));
      when(
        repository.findChildren,
      ).thenAnswer((_) async => const Err(ClientProposalsFailure.network));

      final result = await loadClientProposals();

      expect(result.errorOrNull, ClientProposalsFailure.network);
    });
  });
}
