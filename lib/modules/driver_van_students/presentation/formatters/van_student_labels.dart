import 'package:vanep_mobile/core/domain/schedule/legs_summary.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/formatters/schedule_labels.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/van_student_list.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

const studentDetailSeparator = ' · ';

String familyFilterLabel(AppLocalizations l10n, StudentFamilyFilter filter) {
  return switch (filter) {
    StudentFamilyFilter.all => l10n.vanStudentsFilterAll,
    StudentFamilyFilter.withFamily => l10n.vanStudentsFilterWithFamily,
    StudentFamilyFilter.withoutFamily => l10n.vanStudentsFilterWithoutFamily,
  };
}

String studentShiftLabel(AppLocalizations l10n, DriverStudent student) {
  final schoolShift = student.schoolShift;
  if (schoolShift != null) return formatShift(l10n, schoolShift).toLowerCase();
  return [
    for (final shift in shiftsInUse([student]))
      operationShiftLabel(l10n, shift).toLowerCase(),
  ].join(', ');
}

String studentScheduleDetail(AppLocalizations l10n, DriverStudent student) {
  final legs = summarizeSlots(student.slots);
  return [
    student.schoolName,
    studentShiftLabel(l10n, student),
    if (legs != null) legsSummaryLabel(l10n, legs),
  ].where((part) => part.isNotEmpty).join(studentDetailSeparator);
}

int daysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime(from.year, from.month, from.day);
  final toDay = DateTime(to.year, to.month, to.day);
  final days = toDay.difference(fromDay).inDays;
  return days < 0 ? 0 : days;
}

String invitedAgoLabel(
  AppLocalizations l10n,
  DateTime invitedAt,
  DateTime now,
) {
  final days = daysBetween(invitedAt.toLocal(), now);
  return days == 0
      ? l10n.vanStudentsInvitedToday
      : l10n.vanStudentsInvitedDaysAgo(days);
}

String studentRowSubtitle(
  AppLocalizations l10n,
  DriverStudent student,
  DateTime now,
) {
  final invitedAt = student.invitedAt;
  return switch (student.familyStatus) {
    FamilyStatus.familyJoined => l10n.vanStudentsFamilyJoined,
    FamilyStatus.invited when invitedAt != null => invitedAgoLabel(
      l10n,
      invitedAt,
      now,
    ),
    _ => studentScheduleDetail(l10n, student),
  };
}

String familyNameOf(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  return parts.length > 1 ? parts.last : parts.first;
}

String familyMatchBody(AppLocalizations l10n, FamilyMatch match) {
  final age = match.dependentAge;
  final familyName = familyNameOf(match.clientName);
  return age == null
      ? l10n.vanStudentsMatchBodyWithoutAge(familyName, match.dependentName)
      : l10n.vanStudentsMatchBody(familyName, match.dependentName, age);
}

String familyMatchTitle(AppLocalizations l10n, DriverStudent student) {
  return l10n.vanStudentsMatchTitle(firstNameOf(student.name));
}

String driverStudentFailureMessage(
  AppLocalizations l10n,
  DriverStudentFailure failure,
) {
  return switch (failure) {
    DriverStudentRejectedFailure(:final detail) => detail,
    DriverStudentNetworkFailure() => l10n.vanStudentsNetworkError,
    DriverStudentNotFoundFailure() ||
    DriverStudentUnexpectedFailure() => l10n.vanStudentsActionError,
  };
}

String? unlinkedPassengerErrorText(
  AppLocalizations l10n,
  Set<UnlinkedPassengerDraftError> errors,
  List<UnlinkedPassengerDraftError> candidates,
) {
  for (final error in candidates) {
    if (errors.contains(error)) return unlinkedPassengerErrorLabel(l10n, error);
  }
  return null;
}

String unlinkedPassengerErrorLabel(
  AppLocalizations l10n,
  UnlinkedPassengerDraftError error,
) {
  return switch (error) {
    UnlinkedPassengerDraftError.nameRequired =>
      l10n.unlinkedPassengerErrorNameRequired,
    UnlinkedPassengerDraftError.nameTooLong =>
      l10n.unlinkedPassengerErrorNameTooLong,
    UnlinkedPassengerDraftError.schoolRequired =>
      l10n.unlinkedPassengerErrorSchoolRequired,
    UnlinkedPassengerDraftError.schoolShiftRequired =>
      l10n.unlinkedPassengerErrorSchoolShiftRequired,
    UnlinkedPassengerDraftError.cityRequired ||
    UnlinkedPassengerDraftError.streetRequired ||
    UnlinkedPassengerDraftError.zipCodeInvalid =>
      l10n.postalAddressFieldRequiredError,
    UnlinkedPassengerDraftError.legRequired =>
      l10n.unlinkedPassengerErrorLegRequired,
    UnlinkedPassengerDraftError.timeRequired =>
      l10n.unlinkedPassengerErrorTimeRequired,
    UnlinkedPassengerDraftError.notesTooLong =>
      l10n.unlinkedPassengerErrorNotesTooLong,
  };
}

String cepFailureLabel(AppLocalizations l10n, CepFailure failure) {
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

String catalogFailureLabel(
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

String schoolFailureLabel(AppLocalizations l10n, SchoolFailure failure) {
  return switch (failure) {
    SchoolRejectedFailure(:final detail) =>
      detail.trim().isEmpty ? l10n.vanStudentsActionError : detail,
    SchoolNetworkFailure() => l10n.vanStudentsNetworkError,
    SchoolUnexpectedFailure() => l10n.vanStudentsActionError,
  };
}
