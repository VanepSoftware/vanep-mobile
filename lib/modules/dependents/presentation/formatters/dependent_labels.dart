import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../cubit/dependent_form_state.dart';

String dependentFailureLabel(AppLocalizations l10n, DependentFailure failure) {
  return switch (failure) {
    DependentValidationFailure(:final detail) =>
      detail ?? l10n.dependentFailureValidation,
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
    DependentDraftError.birthDateInFuture =>
      l10n.dependentErrorBirthDateFuture,
    DependentDraftError.birthDateInvalid =>
      l10n.dependentErrorBirthDateInvalid,
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

String dependentAddressLabel(
  AppLocalizations l10n,
  DependentAddress? address,
) {
  if (address == null) return l10n.dependentFieldAddressEmpty;
  final parts = <String>[
    if (hasText(address.number))
      '${address.street}, ${address.number}'
    else
      address.street,
    if (hasText(address.complement)) address.complement!,
    if (hasText(address.district)) address.district!,
    '${address.cityName} - ${address.stateUf}',
  ];
  return parts.join(' · ');
}

int? findAgeInYears(String? birthDate, {DateTime? today}) {
  if (birthDate == null || birthDate.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(birthDate.trim());
  if (parsed == null) return null;
  final reference = today ?? DateTime.now();
  if (parsed.isAfter(reference)) return null;

  var years = reference.year - parsed.year;
  final hadBirthdayThisYear =
      reference.month > parsed.month ||
      (reference.month == parsed.month && reference.day >= parsed.day);
  if (!hadBirthdayThisYear) years -= 1;
  return years;
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
