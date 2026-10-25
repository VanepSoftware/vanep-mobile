import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/formatters/calendar_labels.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';

void main() {
  final l10n = AppLocalizationsPt();

  setUpAll(() => initializeDateFormatting('pt'));

  test('monday to friday collapses into one label', () {
    expect(formatWeekdays(l10n, weekdaysMondayToFriday), 'Seg a sex');
    expect(isMondayToFriday(const [5, 4, 3, 2, 1]), isTrue);
  });

  test('other weekdays are listed in order without dots', () {
    expect(
      formatWeekdays(l10n, const [DateTime.wednesday, DateTime.monday]),
      'Seg, qua',
    );
  });

  test('the first day of the month uses the ordinal', () {
    expect(formatDayMonth(l10n, DateTime(2027, 2)), '1º fev');
    expect(formatDayMonth(l10n, DateTime(2027, 12, 17)), '17 dez');
  });

  test('starting on wraps the day and month', () {
    expect(formatStartingOn(l10n, DateTime(2027, 2)), 'a partir de 1º fev');
  });
}
