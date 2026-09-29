import '../../../../core/domain/iso_calendar_date.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/formatters/postal_code_input_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/failures/ibge_locations_failure.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../cubit/dependent_form_state.dart';

String dependentFailureLabel(AppLocalizations l10n, DependentFailure failure) {
  return switch (failure) {
    DependentValidationFailure() => l10n.dependentFailureValidation,
    DependentCityNotFoundFailure() => l10n.dependentFailureCityNotFound,
    DependentNotFoundFailure() => l10n.dependentFailureNotFound,
    DependentNetworkFailure() => l10n.dependentFailureNetwork,
    DependentUnexpectedFailure() => l10n.dependentFailureUnexpected,
  };
}

String dependentDraftErrorLabel(
  AppLocalizations l10n,
  DependentDraftError code,
) {
  return switch (code) {
    DependentDraftError.nameRequired => l10n.dependentErrorNameRequired,
    DependentDraftError.birthDateInFuture => l10n.dependentErrorBirthDateFuture,
    DependentDraftError.birthDateInvalid => l10n.dependentErrorBirthDateInvalid,
  };
}

String? dependentFieldErrorLabel(
  AppLocalizations l10n,
  DependentFieldError? error,
) {
  return switch (error) {
    LocalDependentFieldError(:final code) => dependentDraftErrorLabel(
      l10n,
      code,
    ),
    BackendDependentFieldError(:final message) => message,
    null => null,
  };
}

String dependentAddressLabel(AppLocalizations l10n, DependentAddress? address) {
  if (address == null) return l10n.dependentFieldAddressEmpty;
  final zipDigits = extractZipDigits(address.zipCode ?? '');
  final parts = <String>[
    if (hasText(address.number))
      '${address.street}, ${address.number}'
    else
      address.street,
    if (hasText(address.complement)) address.complement!,
    if (hasText(address.neighborhood)) address.neighborhood!,
    '${address.cityName} - ${address.stateUf}',
    if (zipDigits.isNotEmpty) formatBrazilianZip(zipDigits),
  ];
  return parts.join(' · ');
}

String dependentCepFailureLabel(AppLocalizations l10n, CepFailure failure) {
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

String dependentCatalogFailureLabel(
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

int? findAgeInYears(String? birthDate, {DateTime? today}) {
  final parsed = parseIsoCalendarDate(birthDate);
  if (parsed == null) return null;
  final reference = today ?? DateTime.now();
  final todayDate = DateTime(reference.year, reference.month, reference.day);
  if (parsed.isAfter(todayDate)) return null;

  var years = todayDate.year - parsed.year;
  final hadBirthdayThisYear =
      todayDate.month > parsed.month ||
      (todayDate.month == parsed.month && todayDate.day >= parsed.day);
  if (!hadBirthdayThisYear) years -= 1;
  return years;
}

bool shouldShowDependentFailureFeedback(DependentFailure? failure) {
  if (failure == null) return false;
  if (failure is DependentCityNotFoundFailure) return false;
  if (failure is DependentValidationFailure && failure.isAttributedToAField) {
    return false;
  }
  return true;
}

String? dependentAgeLabel(
  AppLocalizations l10n,
  String? birthDate, {
  DateTime? today,
}) {
  final years = findAgeInYears(birthDate, today: today);
  if (years == null) return null;
  return l10n.dependentsAgeYears(years);
}
