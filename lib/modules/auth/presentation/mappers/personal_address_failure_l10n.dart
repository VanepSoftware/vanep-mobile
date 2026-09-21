import '../../../../l10n/app_localizations.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/failures/ibge_locations_failure.dart';
import '../../domain/failures/personal_address_failure.dart';

String personalAddressFailureMessage(
  AppLocalizations l10n,
  PersonalAddressFailure failure,
) {
  return switch (failure) {
    PersonalAddressFailure.cityNotFound =>
      l10n.personalAddressFailureCityNotFound,
    PersonalAddressFailure.validation => l10n.personalAddressFailureValidation,
    PersonalAddressFailure.network => l10n.personalAddressFailureNetwork,
    PersonalAddressFailure.unexpected => l10n.personalAddressFailureUnexpected,
  };
}

String cepFailureMessage(AppLocalizations l10n, CepFailure failure) {
  return switch (failure) {
    CepFailure.invalidFormat => l10n.cepFailureInvalidFormat,
    CepFailure.notFound => l10n.cepFailureNotFound,
    CepFailure.cityNotInCatalog => l10n.cepFailureCityNotInCatalog,
    CepFailure.rateLimited => l10n.cepFailureRateLimited,
    CepFailure.unavailable => l10n.cepFailureUnavailable,
    CepFailure.network => l10n.cepFailureNetwork,
    CepFailure.unexpected => l10n.cepFailureUnexpected,
  };
}

String ibgeLocationsFailureMessage(
  AppLocalizations l10n,
  IbgeLocationsFailure failure,
) {
  return switch (failure) {
    IbgeLocationsFailure.ufMissing => l10n.ibgeLocationsFailureUfMissing,
    IbgeLocationsFailure.ufNotFound => l10n.ibgeLocationsFailureUfNotFound,
    IbgeLocationsFailure.network => l10n.ibgeLocationsFailureNetwork,
    IbgeLocationsFailure.unexpected => l10n.ibgeLocationsFailureUnexpected,
  };
}
