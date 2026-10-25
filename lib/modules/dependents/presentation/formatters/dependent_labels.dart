import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/formatters/postal_address_display.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';

String dependentFailureLabel(AppLocalizations l10n, DependentFailure failure) {
  return switch (failure) {
    DependentValidationFailure() => l10n.dependentFailureValidation,
    DependentCityNotFoundFailure() => l10n.dependentFailureCityNotFound,
    DependentNotFoundFailure() => l10n.dependentFailureNotFound,
    DependentNetworkFailure() => l10n.dependentFailureNetwork,
    DependentUnexpectedFailure() => l10n.dependentFailureUnexpected,
    DependentRejectedFailure(:final detail) =>
      detail.trim().isEmpty ? l10n.dependentFailureUnexpected : detail,
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
    DependentDraftError.documentInvalid => l10n.accountIssueDocumentInvalid,
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

String dependentFirstName(String name) {
  final trimmed = name.trim();
  final space = trimmed.indexOf(' ');
  return space < 0 ? trimmed : trimmed.substring(0, space);
}

String? dependentRowSubtitle(
  AppLocalizations l10n,
  Dependent dependent, {
  DateTime? today,
}) {
  final schoolName = dependent.school?.name.trim() ?? '';
  final parts = [
    ?dependentAgeLabel(l10n, dependent.birthDate, today: today),
    if (schoolName.isNotEmpty) schoolName,
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String? dependentSchoolAddressLabel(DependentAddress? address) {
  if (address == null) return null;
  final fields = postalAddressDisplayFields(
    street: address.street,
    number: address.number,
    complement: address.complement,
    neighborhood: address.neighborhood,
    cityName: address.cityName,
    uf: address.stateUf,
  );
  final parts = [
    if (address.street.trim().isNotEmpty) fields.street,
    ?fields.neighborhood,
    if (fields.cityState.isNotEmpty) fields.cityState,
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String? dependentPickupSummary(DependentAddress? address) {
  if (address == null) return null;
  final street = address.street.trim();
  final neighborhood = address.neighborhood?.trim() ?? '';
  final parts = [
    if (street.isNotEmpty)
      joinPostalStreetLine(street: street, number: address.number),
    if (neighborhood.isNotEmpty) neighborhood,
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String dependentEditorTitle(AppLocalizations l10n, DependentWizardStep step) {
  return switch (step) {
    DependentWizardStep.personalData => l10n.dependentRowPersonalData,
    DependentWizardStep.school => l10n.dependentRowSchool,
    DependentWizardStep.schoolDays => l10n.dependentRowSchoolDays,
    DependentWizardStep.pickup => l10n.dependentRowPickup,
  };
}

String dependentReadinessItemLabel(
  AppLocalizations l10n,
  DependentWizardStep step,
) {
  return switch (step) {
    DependentWizardStep.personalData => l10n.dependentFieldBirthDate,
    DependentWizardStep.school => l10n.dependentRowSchool,
    DependentWizardStep.schoolDays => l10n.dependentRowSchoolDays,
    DependentWizardStep.pickup => l10n.dependentRowPickup,
  };
}

String weekdayLabel(AppLocalizations l10n, Weekday day) {
  return switch (day) {
    Weekday.monday => l10n.weekdayMonday,
    Weekday.tuesday => l10n.weekdayTuesday,
    Weekday.wednesday => l10n.weekdayWednesday,
    Weekday.thursday => l10n.weekdayThursday,
    Weekday.friday => l10n.weekdayFriday,
    Weekday.saturday => l10n.weekdaySaturday,
    Weekday.sunday => l10n.weekdaySunday,
  };
}

String weekdayInitial(AppLocalizations l10n, Weekday day) {
  return switch (day) {
    Weekday.monday => l10n.weekdayInitialMonday,
    Weekday.tuesday => l10n.weekdayInitialTuesday,
    Weekday.wednesday => l10n.weekdayInitialWednesday,
    Weekday.thursday => l10n.weekdayInitialThursday,
    Weekday.friday => l10n.weekdayInitialFriday,
    Weekday.saturday => l10n.weekdayInitialSaturday,
    Weekday.sunday => l10n.weekdayInitialSunday,
  };
}

String schoolShiftLabel(AppLocalizations l10n, SchoolShift shift) {
  return switch (shift) {
    SchoolShift.morning => l10n.schoolShiftMorning,
    SchoolShift.afternoon => l10n.schoolShiftAfternoon,
    SchoolShift.night => l10n.schoolShiftNight,
    SchoolShift.fullTime => l10n.schoolShiftFullTime,
  };
}

String dependentSchoolFailureLabel(
  AppLocalizations l10n,
  SchoolFailure failure,
) {
  return switch (failure) {
    SchoolRejectedFailure(:final detail) =>
      detail.trim().isEmpty ? l10n.dependentFailureUnexpected : detail,
    SchoolNetworkFailure() => l10n.dependentFailureNetwork,
    SchoolUnexpectedFailure() => l10n.dependentFailureUnexpected,
  };
}
