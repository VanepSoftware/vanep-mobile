import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';

void main() {
  test('translates all API school shifts to localized labels', () async {
    final pt = await AppLocalizations.delegate.load(const Locale('pt'));
    expect(clientVanShiftLabel(pt, 'MORNING'), 'Manhã');
    expect(clientVanShiftLabel(pt, 'AFTERNOON'), 'Tarde');
    expect(clientVanShiftLabel(pt, 'NIGHT'), 'Noite');
    expect(clientVanShiftLabel(pt, 'FULLTIME'), 'Integral');
    expect(clientVanShiftLabel(pt, 'Manhã'), 'Manhã');
    expect(clientVanShiftLabel(pt, ''), '');

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(clientVanShiftLabel(en, 'MORNING'), 'Morning');
    expect(clientVanShiftLabel(en, 'AFTERNOON'), 'Afternoon');
    expect(clientVanShiftLabel(en, 'NIGHT'), 'Night');
    expect(clientVanShiftLabel(en, 'FULLTIME'), 'Full-time');
  });
}
