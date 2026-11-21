import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_action.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';

String documentAboutText(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.driverLicense => l10n.documentAboutDriverLicense,
    DocumentType.schoolDriverCourse => l10n.documentAboutSchoolDriverCourse,
    DocumentType.criminalRecord => l10n.documentAboutCriminalRecord,
    DocumentType.municipalAuthorization =>
      l10n.documentAboutMunicipalAuthorization,
    DocumentType.vehicleRegistration => l10n.documentAboutVehicleRegistration,
    DocumentType.vehicleInspection => l10n.documentAboutVehicleInspection,
    DocumentType.schoolVehicleAuthorization =>
      l10n.documentAboutSchoolVehicleAuthorization,
  };
}

String documentIssuer(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.schoolDriverCourse => l10n.documentIssuerCourse,
    DocumentType.criminalRecord => l10n.documentIssuerCriminalRecord,
    DocumentType.municipalAuthorization =>
      l10n.documentIssuerMunicipalAuthorization,
    DocumentType.driverLicense ||
    DocumentType.vehicleRegistration ||
    DocumentType.vehicleInspection ||
    DocumentType.schoolVehicleAuthorization => l10n.documentIssuerDetran,
  };
}

String? documentTypicalValidity(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.driverLicense => l10n.documentValidityDriverLicense,
    DocumentType.schoolDriverCourse => l10n.documentValidityCourse,
    DocumentType.municipalAuthorization =>
      l10n.documentValidityMunicipalAuthorization,
    DocumentType.vehicleRegistration =>
      l10n.documentValidityVehicleRegistration,
    DocumentType.vehicleInspection => l10n.documentValidityVehicleInspection,
    DocumentType.criminalRecord ||
    DocumentType.schoolVehicleAuthorization => null,
  };
}

String rejectionReasonLabel(AppLocalizations l10n, RejectionReason? reason) {
  return switch (reason) {
    RejectionReason.illegible => l10n.documentRejectionIllegible,
    RejectionReason.expired => l10n.documentRejectionExpired,
    RejectionReason.dataMismatch => l10n.documentRejectionDataMismatch,
    RejectionReason.wrongType => l10n.documentRejectionWrongType,
    RejectionReason.incomplete => l10n.documentRejectionIncomplete,
    RejectionReason.other || null => l10n.documentRejectionOther,
  };
}

String documentActionLabel(AppLocalizations l10n, DocumentAction action) {
  return switch (action) {
    DocumentAction.send => l10n.documentActionSend,
    DocumentAction.finish => l10n.documentActionFinish,
    DocumentAction.resend => l10n.documentActionResend,
    DocumentAction.sendNew => l10n.documentActionSendNew,
    DocumentAction.sendUpdated => l10n.documentActionSendUpdated,
  };
}

String? documentStateNote(AppLocalizations l10n, DocumentDisplayState state) {
  return switch (state) {
    DocumentUnderReview() => l10n.documentDetailUnderReviewNote,
    DocumentExpiringSoon() => l10n.documentDetailExpiringNote,
    DocumentExpired() => l10n.documentDetailExpiredNote,
    DocumentIncomplete() => l10n.documentDetailIncompleteNote,
    DocumentRenewalUnderReview() => l10n.documentDetailRenewalNote,
    _ => null,
  };
}

String? documentStateDate(
  AppLocalizations l10n,
  DocumentDisplayState state,
  RequirementStatus requirement,
) {
  final current = requirement.current;
  final expiresAt = current?.expiresAt;
  final reviewedAt = current?.reviewedAt;
  return switch (state) {
    DocumentNotSent(:final isOptional) =>
      isOptional ? l10n.documentStateOptional : null,
    DocumentIncomplete() => sentOnDate(
      l10n,
      incompleteSubmissionOf(requirement)?.createdAt,
    ),
    DocumentUnderReview() => sentOnDate(l10n, current?.createdAt),
    DocumentRejected() =>
      reviewedAt == null ? null : formatDayMonthAndTime(l10n, reviewedAt),
    DocumentExpired() ||
    DocumentExpiringSoon() ||
    DocumentApproved() ||
    DocumentRenewalUnderReview() =>
      expiresAt != null
          ? l10n.documentDetailValidUntilDate(
              formatNumericDate(l10n, expiresAt),
            )
          : reviewedAt == null
          ? null
          : l10n.documentDetailApprovedOn(
              formatNumericDate(l10n, reviewedAt.toLocal()),
            ),
  };
}

String? sentOnDate(AppLocalizations l10n, DateTime? createdAt) {
  return createdAt == null
      ? null
      : l10n.documentDetailSentOnDate(
          formatNumericDate(l10n, createdAt.toLocal()),
        );
}
