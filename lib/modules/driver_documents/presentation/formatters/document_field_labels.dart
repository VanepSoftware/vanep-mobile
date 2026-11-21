import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/formatters/birth_date_input_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_field_rules.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

String documentFieldLabel(
  AppLocalizations l10n,
  DocumentType type,
  DocumentField field,
) {
  return switch (field) {
    DocumentField.documentNumber => documentNumberLabel(l10n, type),
    DocumentField.expiresAt => documentExpiryLabel(l10n, type),
    DocumentField.cnhRegistrationNumber => l10n.documentFieldCnhRegistration,
    DocumentField.cnhCategory => l10n.documentFieldCnhCategory,
    DocumentField.cnhIssueDate => l10n.documentFieldCnhIssueDate,
    DocumentField.cnhIssuingState => l10n.documentFieldCnhIssuingState,
  };
}

String documentFieldRuleLabel(
  AppLocalizations l10n,
  DocumentType type,
  FieldRule rule,
) {
  final label = documentFieldLabel(l10n, type, rule.field);
  return rule.required ? label : l10n.documentFieldOptional(label);
}

String documentNumberLabel(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.schoolDriverCourse => l10n.documentFieldCertificateNumber,
    DocumentType.municipalAuthorization => l10n.documentFieldMunicipalNumber,
    DocumentType.vehicleInspection => l10n.documentFieldReportNumber,
    DocumentType.schoolVehicleAuthorization =>
      l10n.documentFieldAuthorizationNumber,
    DocumentType.criminalRecord ||
    DocumentType.vehicleRegistration ||
    DocumentType.driverLicense => l10n.documentFieldNumber,
  };
}

String documentExpiryLabel(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.driverLicense => l10n.documentFieldCnhValidity,
    DocumentType.criminalRecord ||
    DocumentType.vehicleInspection ||
    DocumentType.schoolVehicleAuthorization =>
      l10n.documentFieldValidUntilFeminine,
    DocumentType.schoolDriverCourse ||
    DocumentType.municipalAuthorization ||
    DocumentType.vehicleRegistration => l10n.documentFieldValidUntilMasculine,
  };
}

String? documentFieldHint(
  AppLocalizations l10n,
  DocumentType type,
  DocumentField field,
) {
  if (field == DocumentField.expiresAt &&
      type == DocumentType.vehicleRegistration) {
    return l10n.documentCrlvExpiryHint;
  }
  return null;
}

String documentFieldErrorMessage(
  AppLocalizations l10n,
  DocumentField field,
  DocumentFieldError error,
) {
  return switch (error) {
    DocumentFieldError.required => l10n.documentFieldErrorRequired,
    DocumentFieldError.tooLong => l10n.documentFieldErrorTooLong,
    DocumentFieldError.alreadyExpired => l10n.documentFieldErrorAlreadyExpired,
    DocumentFieldError.tooFar => l10n.documentFieldErrorTooFar,
    DocumentFieldError.beforeIssue => l10n.documentFieldErrorBeforeIssue,
    DocumentFieldError.inFuture => l10n.documentFieldErrorInFuture,
    DocumentFieldError.invalidFormat => switch (field) {
      DocumentField.cnhRegistrationNumber =>
        l10n.documentFieldErrorCnhRegistration,
      DocumentField.cnhCategory => l10n.documentFieldErrorCnhCategory,
      DocumentField.cnhIssuingState => l10n.documentFieldErrorIssuingState,
      DocumentField.expiresAt ||
      DocumentField.cnhIssueDate => l10n.documentFieldErrorInvalidDate,
      DocumentField.documentNumber => l10n.documentFieldErrorInvalid,
    },
  };
}

String documentFileFormatLabel(AppLocalizations l10n, String mimeType) {
  return switch (mimeType) {
    'application/pdf' => l10n.documentFormatPdf,
    'image/png' => l10n.documentFormatPng,
    'image/webp' => l10n.documentFormatWebp,
    _ => l10n.documentFormatJpg,
  };
}

DateTime? parseDocumentDateInput(String text) {
  final iso = birthDateInputToIso(text);
  return iso == null ? null : parseIsoCalendarDate(iso);
}

bool isFilledDateInput(String text) =>
    text.replaceAll(RegExp(r'\D'), '').length == birthDateDigitCount;

String formatDocumentDateInput(DateTime? date) =>
    date == null ? '' : isoToBirthDateInput(formatIsoCalendarDate(date));
