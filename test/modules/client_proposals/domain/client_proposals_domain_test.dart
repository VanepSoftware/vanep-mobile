import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';

void main() {
  group('the open negotiations', () {
    test('a proposal to answer is pending, the rest waits for the driver', () {
      final feed = testClientProposals().feed;

      expect(feed.pending, [testProposalForSiblings]);
      expect(feed.awaiting, [
        testAdjustmentForPedro,
        testRequestForLucas,
        testRequestForRemovedChild,
      ]);
    });
  });

  group('the filter by child', () {
    test('a negotiation for two siblings shows for each of them', () {
      final proposals = testClientProposals();

      expect(proposals.feedFor(testAna.token).pending, [
        testProposalForSiblings,
      ]);
      expect(proposals.feedFor(testPedro.token).pending, [
        testProposalForSiblings,
      ]);
      expect(proposals.feedFor(testPedro.token).awaiting, [
        testAdjustmentForPedro,
      ]);
    });

    test('a removed dependent shows only under every child', () {
      final proposals = testClientProposals();

      expect(
        proposals.feedFor(null).open,
        contains(testRequestForRemovedChild),
      );
      for (final child in proposals.children) {
        expect(
          proposals.feedFor(child.token).open,
          isNot(contains(testRequestForRemovedChild)),
        );
      }
    });

    test('the closed ones of a child are the loaded ones of that child', () {
      final feed = testClientProposals(closedCount: 25).feedFor(testAna.token);

      expect(feed.closed, [testClosedForAna]);
      expect(feed.closedCount, 1);
    });

    test('without a filter the closed count is the total of the back', () {
      expect(
        testClientProposals(closedCount: 25).feedFor(null).closedCount,
        25,
      );
    });

    test('only more than one dependent can be filtered', () {
      expect(testClientProposals().canFilterByChild, isTrue);
      expect(
        testClientProposals(children: const [testPedro]).canFilterByChild,
        isFalse,
      );
    });
  });

  group('the open requests counter', () {
    test('counts the whole account whatever the filter', () {
      final proposals = testClientProposals();

      expect(proposals.openRequestsCount, 4);
      expect(proposals.feedFor(testLucas.token).openCount, 1);
      expect(proposals.hasReachedOpenRequestsLimit, isFalse);
    });

    test('five open negotiations reach the limit', () {
      final proposals = testClientProposals(
        open: [
          ...testOpenRequests,
          TestClientServiceRequest(token: 'fifth'),
        ],
      );

      expect(proposals.hasReachedOpenRequestsLimit, isTrue);
    });
  });

  test('a next closed page adds its items and says if there are more', () {
    final next = TestClientServiceRequest(
      token: 'request-closed-old',
      status: ServiceRequestStatus.expired,
    );

    final proposals = testClientProposals(hasMoreClosed: true).withClosedPage(
      NegotiationPage(items: [next], isLast: true, totalElements: 3),
      page: 1,
    );

    expect(proposals.feed.closed, [testClosedForPedro, testClosedForAna, next]);
    expect(proposals.feed.closedCount, 3);
    expect(proposals.closedPage, 1);
    expect(proposals.hasMoreClosed, isFalse);
  });

  test('a next closed page skips what the list already has', () {
    final next = TestClientServiceRequest(
      token: 'request-closed-old',
      status: ServiceRequestStatus.expired,
    );

    final proposals = testClientProposals(hasMoreClosed: true).withClosedPage(
      NegotiationPage(
        items: [testClosedForAna, next],
        isLast: true,
        totalElements: 3,
      ),
      page: 1,
    );

    expect(proposals.feed.closed, [testClosedForPedro, testClosedForAna, next]);
  });

  test('a withdrawn request leaves the open ones and closes first', () {
    final withdrawn = TestClientServiceRequest(
      token: testRequestForLucas.token,
      status: ServiceRequestStatus.withdrawn,
    );

    final proposals = testClientProposals().withRequestClosed(withdrawn);

    expect(proposals.feed.open, isNot(contains(testRequestForLucas)));
    expect(proposals.openRequestsCount, 3);
    expect(proposals.feed.closed.first, withdrawn);
    expect(proposals.feed.closedCount, 3);
  });
}
