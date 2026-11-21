import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

const int maxDocumentNumberLength = 64;

const List<String> cnhCategories = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'AB',
  'AC',
  'AD',
  'AE',
];

final RegExp cnhRegistrationPattern = RegExp(r'^\d{9,11}$');

final RegExp issuingStatePattern = RegExp(r'^[A-Z]{2}$');

class FieldRule extends Equatable {
  const FieldRule(this.field, {required this.required});

  final DocumentField field;
  final bool required;

  @override
  List<Object?> get props => [field, required];
}

List<FieldRule> fieldRulesFor(DocumentType type) {
  const optionalNumber = FieldRule(
    DocumentField.documentNumber,
    required: false,
  );
  const requiredNumber = FieldRule(
    DocumentField.documentNumber,
    required: true,
  );
  const optionalExpiry = FieldRule(DocumentField.expiresAt, required: false);
  const requiredExpiry = FieldRule(DocumentField.expiresAt, required: true);
  return switch (type) {
    DocumentType.criminalRecord ||
    DocumentType.schoolDriverCourse => const [optionalNumber, optionalExpiry],
    DocumentType.municipalAuthorization => const [
      requiredNumber,
      optionalExpiry,
    ],
    DocumentType.vehicleRegistration => const [requiredExpiry, optionalNumber],
    DocumentType.vehicleInspection => const [optionalNumber, requiredExpiry],
    DocumentType.schoolVehicleAuthorization => const [
      requiredNumber,
      requiredExpiry,
    ],
    DocumentType.driverLicense => const [
      FieldRule(DocumentField.cnhRegistrationNumber, required: true),
      FieldRule(DocumentField.cnhCategory, required: true),
      FieldRule(DocumentField.cnhIssueDate, required: true),
      requiredExpiry,
      FieldRule(DocumentField.cnhIssuingState, required: false),
    ],
  };
}

DateTime? latestExpiryFor(DocumentType type, DateTime asOf) {
  return switch (type) {
    DocumentType.vehicleRegistration => DateTime(asOf.year + 1, 12, 31),
    DocumentType.vehicleInspection => addCalendarMonths(asOf, 7),
    DocumentType.schoolVehicleAuthorization => addCalendarMonths(asOf, 24),
    DocumentType.schoolDriverCourse ||
    DocumentType.municipalAuthorization => addCalendarMonths(asOf, 60),
    DocumentType.criminalRecord || DocumentType.driverLicense => null,
  };
}

bool cnhCategoryAllowsSchoolTransport(String category) {
  final normalized = category.toUpperCase();
  return normalized.contains('D') || normalized.contains('E');
}

Map<DocumentField, DocumentFieldError> validateDocumentDraft(
  DocumentDraft draft,
  DateTime asOf,
) {
  return switch (draft) {
    PersonalDocumentDraft() => validateNumberAndExpiry(
      draft.type,
      draft.documentNumber,
      draft.expiresAt,
      asOf,
    ),
    VehicleDocumentDraft() => validateNumberAndExpiry(
      draft.type,
      draft.documentNumber,
      draft.expiresAt,
      asOf,
    ),
    CnhDraft() => validateCnhDraft(draft, asOf),
  };
}

Map<DocumentField, DocumentFieldError> validateNumberAndExpiry(
  DocumentType type,
  String? documentNumber,
  DateTime? expiresAt,
  DateTime asOf,
) {
  final errors = <DocumentField, DocumentFieldError>{};
  final rules = fieldRulesFor(type);
  final numberError = validateDocumentNumber(
    documentNumber,
    required: isRequired(rules, DocumentField.documentNumber),
  );
  if (numberError != null) errors[DocumentField.documentNumber] = numberError;
  final expiryError = validateExpiry(
    expiresAt,
    required: isRequired(rules, DocumentField.expiresAt),
    asOf: asOf,
    latest: latestExpiryFor(type, asOf),
  );
  if (expiryError != null) errors[DocumentField.expiresAt] = expiryError;
  return errors;
}

bool isRequired(List<FieldRule> rules, DocumentField field) =>
    rules.any((rule) => rule.field == field && rule.required);

DocumentFieldError? validateDocumentNumber(
  String? number, {
  required bool required,
}) {
  final trimmed = number?.trim() ?? '';
  if (trimmed.isEmpty) return required ? DocumentFieldError.required : null;
  if (trimmed.length > maxDocumentNumberLength) {
    return DocumentFieldError.tooLong;
  }
  return null;
}

DocumentFieldError? validateExpiry(
  DateTime? expiresAt, {
  required bool required,
  required DateTime asOf,
  DateTime? latest,
}) {
  if (expiresAt == null) return required ? DocumentFieldError.required : null;
  if (expiresAt.isBefore(asOf)) return DocumentFieldError.alreadyExpired;
  if (latest != null && expiresAt.isAfter(latest)) {
    return DocumentFieldError.tooFar;
  }
  return null;
}

Map<DocumentField, DocumentFieldError> validateCnhDraft(
  CnhDraft draft,
  DateTime asOf,
) {
  final errors = {
    DocumentField.cnhRegistrationNumber: validateCnhRegistration(
      draft.registrationNumber,
    ),
    DocumentField.cnhCategory: validateCnhCategory(draft.category),
    DocumentField.cnhIssueDate: validateCnhIssueDate(draft.issueDate, asOf),
    DocumentField.expiresAt: validateCnhValidity(
      draft.validUntil,
      draft.issueDate,
      asOf,
    ),
    DocumentField.cnhIssuingState: validateIssuingState(draft.issuingState),
  };
  return {for (final MapEntry(:key, :value) in errors.entries) key: ?value};
}

DocumentFieldError? validateCnhRegistration(String registrationNumber) {
  final registration = registrationNumber.trim();
  if (registration.isEmpty) return DocumentFieldError.required;
  return cnhRegistrationPattern.hasMatch(registration)
      ? null
      : DocumentFieldError.invalidFormat;
}

DocumentFieldError? validateCnhCategory(String rawCategory) {
  final category = rawCategory.trim().toUpperCase();
  if (category.isEmpty) return DocumentFieldError.required;
  return cnhCategories.contains(category)
      ? null
      : DocumentFieldError.invalidFormat;
}

DocumentFieldError? validateCnhIssueDate(DateTime? issueDate, DateTime asOf) {
  if (issueDate == null) return DocumentFieldError.required;
  return issueDate.isAfter(asOf) ? DocumentFieldError.inFuture : null;
}

DocumentFieldError? validateIssuingState(String? issuingState) {
  final state = issuingState?.trim() ?? '';
  if (state.isEmpty) return null;
  return issuingStatePattern.hasMatch(state)
      ? null
      : DocumentFieldError.invalidFormat;
}

DocumentFieldError? validateCnhValidity(
  DateTime? validUntil,
  DateTime? issueDate,
  DateTime asOf,
) {
  if (validUntil == null) return DocumentFieldError.required;
  if (issueDate != null && !validUntil.isAfter(issueDate)) {
    return DocumentFieldError.beforeIssue;
  }
  if (validUntil.isBefore(asOf)) return DocumentFieldError.alreadyExpired;
  if (issueDate != null &&
      validUntil.isAfter(addCalendarMonths(issueDate, 120))) {
    return DocumentFieldError.tooFar;
  }
  return null;
}
