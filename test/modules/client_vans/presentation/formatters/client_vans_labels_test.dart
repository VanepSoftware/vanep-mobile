import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';

void main() {
  test('translates all SchoolShift values to localized labels and omits null', () async {
    final pt = await AppLocalizations.delegate.load(const Locale('pt'));
    expect(clientVanShiftLabel(pt, SchoolShift.morning), 'Manhã');
    expect(clientVanShiftLabel(pt, SchoolShift.afternoon), 'Tarde');
    expect(clientVanShiftLabel(pt, SchoolShift.night), 'Noite');
    expect(clientVanShiftLabel(pt, SchoolShift.fullTime), 'Integral');
    expect(clientVanShiftLabel(pt, null), '');

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(clientVanShiftLabel(en, SchoolShift.morning), 'Morning');
    expect(clientVanShiftLabel(en, SchoolShift.afternoon), 'Afternoon');
    expect(clientVanShiftLabel(en, SchoolShift.night), 'Night');
    expect(clientVanShiftLabel(en, SchoolShift.fullTime), 'Full-time');
    expect(clientVanShiftLabel(en, null), '');
  });

  test('returns null contract period when startsOn or endsOn is missing', () async {
    final pt = await AppLocalizations.delegate.load(const Locale('pt'));
    const partial = ClientVanContract(token: 'c1', status: 'ACTIVE');
    expect(clientVanContractPeriod(pt, partial), isNull);
    expect(clientVanInstallmentText(pt, partial), '');
  });
}
