import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';

String serviceAreaFailureLabel(
  AppLocalizations l10n,
  ServiceAreaFailure failure,
) {
  return switch (failure) {
    ServiceAreaFailure.districtRequired =>
      l10n.serviceAreaFailureDistrictRequired,
    ServiceAreaFailure.tooManyAreas => l10n.serviceAreaFailureTooMany,
    ServiceAreaFailure.placeNotResolved =>
      l10n.serviceAreaFailurePlaceNotResolved,
    ServiceAreaFailure.cityUnmatched => l10n.placesCityUnmatched,
    ServiceAreaFailure.rateLimited => l10n.serviceAreaFailureRateLimited,
    ServiceAreaFailure.network => l10n.serviceAreaFailureNetwork,
    ServiceAreaFailure.unexpected => l10n.serviceAreaFailureUnexpected,
  };
}
