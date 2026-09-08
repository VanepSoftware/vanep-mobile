import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/driver_search_failure.dart';

String driverSearchFailureLabel(
  AppLocalizations l10n,
  DriverSearchFailure failure,
) {
  return switch (failure) {
    DriverSearchFailure.placeNotResolved => l10n.driverSearchPlaceNotResolved,
    DriverSearchFailure.rateLimited => l10n.driverSearchRateLimited,
    DriverSearchFailure.network => l10n.driverSearchNetworkError,
    DriverSearchFailure.unexpected => l10n.driverSearchUnexpectedError,
  };
}
