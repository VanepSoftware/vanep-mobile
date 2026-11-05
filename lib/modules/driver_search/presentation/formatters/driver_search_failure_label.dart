import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';

String driverSearchFailureLabel(
  AppLocalizations l10n,
  DriverSearchFailure failure,
) {
  return switch (failure) {
    DriverSearchFailure.placeNotResolved => l10n.driverSearchPlaceNotResolved,
    DriverSearchFailure.cityUnmatched => l10n.placesCityUnmatched,
    DriverSearchFailure.rateLimited => l10n.driverSearchRateLimited,
    DriverSearchFailure.network => l10n.driverSearchNetworkError,
    DriverSearchFailure.unexpected => l10n.driverSearchUnexpectedError,
  };
}
