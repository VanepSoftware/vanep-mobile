import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';

void main() {
  final now = DateTime(2026, 10, 12, 18);

  test('a message from today shows the time', () {
    expect(
      formatConversationListTime(DateTime(2026, 10, 12, 9, 5), now: now),
      '09:05',
    );
  });

  test('an older message shows the day', () {
    expect(
      formatConversationListTime(DateTime(2026, 10, 3, 9, 5), now: now),
      '03/10',
    );
  });
}
