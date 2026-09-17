import '../../../../core/domain/iso_calendar_date.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/dependent_failure.dart';
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
