import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final date = DateTime(2026, 11, 16);

  test('writes day before month in Portuguese', () {
    final l10n = lookupAppLocalizations(const Locale('pt'));

    expect(formatDayMonth(l10n, date), '16/11');
  });

  test('writes month before day in English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(formatDayMonth(l10n, date), '11/16');
  });
}
