import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

void main() {
  group('formatDepartureTime', () {
    test('uses the "h" format in Portuguese', () {
      expect(formatDepartureTime(380, languageCode: 'pt'), '6h20');
      expect(formatDepartureTime(700, languageCode: 'pt'), '11h40');
    });

    test('drops the minutes when they are zero in Portuguese', () {
      expect(formatDepartureTime(360, languageCode: 'pt'), '6h');
    });

    test('uses the clock format outside Portuguese', () {
      expect(formatDepartureTime(380, languageCode: 'en'), '6:20');
      expect(formatDepartureTime(360, languageCode: 'en'), '6:00');
    });
  });

  group('daysUntilInviteExpires', () {
    final now = DateTime(2026, 10, 25, 12);

    test('counts whole days', () {
      expect(daysUntilInviteExpires(DateTime(2026, 10, 28, 13), now), 3);
    });

    test('is zero when less than a day is left', () {
      expect(daysUntilInviteExpires(DateTime(2026, 10, 26, 8), now), 0);
    });
  });

  group('assistantInitialsOf', () {
    test('takes the first two names', () {
      expect(assistantInitialsOf('João Pedro Lima'), 'JP');
    });

    test('takes one letter for a single name', () {
      expect(assistantInitialsOf('carlos'), 'C');
    });

    test('is empty for a blank name', () {
      expect(assistantInitialsOf('   '), '');
    });
  });

  test('firstNameOf returns the first word', () {
    expect(firstNameOf('Carlos Mendes'), 'Carlos');
  });
}
