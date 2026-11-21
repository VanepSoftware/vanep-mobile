import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_action.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';

const int expiringSoonWindowDays = 30;

DocumentDisplayState resolveDocumentDisplayState(
  RequirementStatus requirement,
  DateTime asOf,
) {
  if (hasPendingWithoutFile(requirement)) return const DocumentIncomplete();
  return switch (requirement.state) {
    ComplianceState.missing => DocumentNotSent(
      isOptional: requirement.optional,
    ),
    ComplianceState.rejected => const DocumentRejected(),
    ComplianceState.expired => const DocumentExpired(),
    ComplianceState.pending => const DocumentUnderReview(),
    ComplianceState.approved => resolveApprovedState(requirement, asOf),
  };
}

bool hasPendingWithoutFile(RequirementStatus requirement) =>
    incompleteSubmissionOf(requirement) != null;

DocumentDisplayState resolveApprovedState(
  RequirementStatus requirement,
  DateTime asOf,
) {
  if (requirement.pending != null) return const DocumentRenewalUnderReview();
  final daysLeft = daysUntilExpiry(requirement.current, asOf);
  final isExpiring =
      requirement.expiringSoon ??
      (daysLeft != null && daysLeft <= expiringSoonWindowDays);
  return isExpiring && daysLeft != null
      ? DocumentExpiringSoon(daysLeft: daysLeft)
      : const DocumentApproved();
}

int? daysUntilExpiry(DocumentSubmission? submission, DateTime asOf) {
  final expiresAt = submission?.expiresAt;
  if (expiresAt == null) return null;
  final days = calendarDaysBetween(asOf, expiresAt);
  return days < 0 ? null : days;
}
