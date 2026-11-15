import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await initializeDateFormatting('pt');
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test('shows a calendar date without the abbreviation dot', () {
    expect(formatCalendarDate(l10n, DateTime(2027, 2, 15)), '15 fev 2027');
  });

  test('shows a calendar date in numbers for a date field', () {
    expect(formatNumericDate(l10n, DateTime(2027, 2, 1)), '01/02/2027');
  });

  test('a range in the same year shows the year only at the end', () {
    expect(
      formatCalendarRange(l10n, DateTime(2027, 2, 15), DateTime(2027, 12, 17)),
      '15 fev a 17 dez 2027',
    );
    expect(
      formatCalendarRange(l10n, DateTime(2026, 11, 3), DateTime(2027, 6, 30)),
      '3 nov 2026 a 30 jun 2027',
    );
  });

  test('shows the day and the month, with the time when asked', () {
    final moment = DateTime(2026, 10, 25, 13, 40);

    expect(formatDayAndMonth(l10n, moment), '25/10');
    expect(formatDayMonthAndTime(l10n, moment), '25/10 13:40');
  });
}
