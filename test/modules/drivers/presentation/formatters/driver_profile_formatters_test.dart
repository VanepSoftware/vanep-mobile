import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';

import '../../drivers_fixtures.dart';

void main() {
  final l10n = AppLocalizationsPt();
  final van = testDriverProfile.vehicles.single;

  test('titles the van by model, year and brand', () {
    expect(formatVanTitle(l10n, van), 'Sprinter 2021 · Mercedes-Benz');
  });

  test('describes the van by seats and color', () {
    expect(formatVanDetails(l10n, van), '15 lugares · Branca');
  });

  test('lists the regions by their full names, skipping blanks', () {
    expect(
      formatServiceAreaList(const ['Taguatinga', ' ', 'Águas Claras']),
      'Taguatinga, Águas Claras',
    );
  });

  test('labels a missing driver apart from a loading error', () {
    expect(
      driverProfileFailureLabel(l10n, const NotFoundDriverFailure()),
      'Este motorista não está mais disponível.',
    );
    expect(
      driverProfileFailureLabel(l10n, const NetworkDriverFailure()),
      'Não foi possível carregar o motorista. Tente novamente.',
    );
    expect(
      driverProfileFailureLabel(l10n, const UnexpectedDriverFailure()),
      'Não foi possível carregar o motorista. Tente novamente.',
    );
  });
}
