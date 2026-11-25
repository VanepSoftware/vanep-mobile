import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';

import '../push_notifications_fixtures.dart';

void main() {
  test('chat data becomes a chat target', () {
    expect(pushNavigationTargetFrom(chatPushData), chatPushTarget);
  });

  test('chat without a conversation token has no target', () {
    expect(pushNavigationTargetFrom(const {'type': 'chat'}), isNull);
  });

  test('chat without a counterpart name keeps an empty name', () {
    expect(
      pushNavigationTargetFrom(const {
        'type': 'chat',
        'conversationToken': 'conv-1',
      }),
      const ChatPushTarget(conversationToken: 'conv-1', counterpartName: ''),
    );
  });

  test('proposal types in English and Portuguese open proposals', () {
    for (final type in ['proposal', 'proposta', 'PROPOSTA']) {
      expect(
        pushNavigationTargetFrom({'type': type}),
        const ProposalPushTarget(),
      );
    }
  });

  test('contract types in English and Portuguese open contracts', () {
    for (final type in ['contract', 'contrato']) {
      expect(
        pushNavigationTargetFrom({'type': type}),
        const ContractPushTarget(),
      );
    }
  });

  test('unknown, missing or non-text types have no target', () {
    expect(pushNavigationTargetFrom(const {'type': 'promo'}), isNull);
    expect(pushNavigationTargetFrom(const {}), isNull);
    expect(pushNavigationTargetFrom(const {'type': 1}), isNull);
  });
}
