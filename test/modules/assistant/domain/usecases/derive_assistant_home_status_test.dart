import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';

void main() {
  group('deriveAssistantHomeStatus', () {
    test('no link and no invite is the no-van state', () {
      final status = deriveAssistantHomeStatus(links: const []);

      expect(status, const AssistantHomeNoVan());
    });

    test('an invite without an active link is the invite state', () {
      final status = deriveAssistantHomeStatus(
        links: const [],
        pendingInvite: testAssistantInvite,
      );

      expect(status, AssistantHomeInviteReceived(testAssistantInvite));
    });

    test('an active link without a running trip is before the route', () {
      final status = deriveAssistantHomeStatus(
        links: [testLinkCarlosActive],
        route: testRouteNotStarted(),
      );

      expect(status, isA<AssistantHomeBeforeRoute>());
    });

    test('an active link with no trip today is before the route', () {
      final status = deriveAssistantHomeStatus(links: [testLinkCarlosActive]);

      expect(status, AssistantHomeBeforeRoute(link: testLinkCarlosActive));
    });

    test('a running trip at a home pickup is on route, boarding', () {
      final route = testRouteOnPickup();
      final status = deriveAssistantHomeStatus(
        links: [testLinkCarlosActive],
        route: route,
      );

      expect(
        status,
        AssistantHomeOnRouteBoarding(
          link: testLinkCarlosActive,
          route: route,
          stop: route.stops[2],
        ),
      );
    });

    test('a running trip at a school is on route, dropping off', () {
      final status = deriveAssistantHomeStatus(
        links: [testLinkCarlosActive],
        route: testRouteAtSchool(),
      );

      expect(status, isA<AssistantHomeOnRouteDropOff>());
    });

    test('a paused selected van is the paused state with the other vans', () {
      final status = deriveAssistantHomeStatus(
        links: [testLinkCarlosPaused, testLinkRitaActive],
        selectedVanToken: testAssistantVanPrimary.token,
      );

      expect(
        status,
        AssistantHomeAccessPaused(
          link: testLinkCarlosPaused,
          otherActiveLinks: [testLinkRitaActive],
        ),
      );
    });

    test('an invite does not take over when a van is active', () {
      final status = deriveAssistantHomeStatus(
        links: [testLinkCarlosActive],
        pendingInvite: testAssistantInvite,
      );

      expect(status, isA<AssistantHomeBeforeRoute>());
    });
  });

  group('selectAssistantVanLink', () {
    test('keeps the selected van when it is still linked', () {
      final link = selectAssistantVanLink([
        testLinkCarlosActive,
        testLinkRitaActive,
      ], testAssistantVanSecondary.token);

      expect(link, testLinkRitaActive);
    });

    test('without a selection prefers an active van', () {
      final link = selectAssistantVanLink([
        testLinkCarlosPaused,
        testLinkRitaActive,
      ], null);

      expect(link, testLinkRitaActive);
    });

    test('a selection that is no longer linked falls back to the default', () {
      final link = selectAssistantVanLink([
        testLinkCarlosPaused,
        testLinkRitaActive,
      ], 'van-that-left');

      expect(link, testLinkRitaActive);
    });

    test('without a selection prefers the active van of the current shift', () {
      final afternoon = DateTime(2026, 10, 14, 14);

      final link = selectAssistantVanLink(
        [testLinkCarlosActive, testLinkRitaActive],
        null,
        now: afternoon,
      );

      expect(link, testLinkRitaActive);
    });

    test('in the morning the morning van comes first', () {
      final morning = DateTime(2026, 10, 14, 6);

      final link = selectAssistantVanLink(
        [testLinkRitaActive, testLinkCarlosActive],
        null,
        now: morning,
      );

      expect(link, testLinkCarlosActive);
    });

    test('with only paused vans picks the first one', () {
      final link = selectAssistantVanLink([testLinkCarlosPaused], null);

      expect(link?.status, AssistantLinkStatus.inactive);
    });
  });
}
