import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test('the week days in full, short and as initials', () {
    expect(
      [for (final day in Weekday.values) weekdayLabel(l10n, day)],
      ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'],
    );
    expect(
      [for (final day in Weekday.values) weekdayShortLabel(l10n, day)],
      ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
    );
    expect(
      [for (final day in Weekday.values) weekdayInitial(l10n, day)],
      ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
    );
  });

  test('a list of weekdays reads Monday to Friday as a range', () {
    expect(formatWeekdayList(l10n, weekdaysMondayToFriday), 'Seg a sex');
    expect(
      formatWeekdayList(l10n, const [Weekday.monday, Weekday.wednesday]),
      'Seg, Qua',
    );
  });
}
