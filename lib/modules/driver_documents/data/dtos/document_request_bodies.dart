import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/document_json_readers.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

Map<String, Object?> documentRequestBody(DocumentDraft draft) {
  return switch (draft) {
    PersonalDocumentDraft() => {
      'documentType': draft.type.documentApiName,
      'documentNumber': trimmedOrNull(draft.documentNumber),
      'expiresAt': calendarDateOrNull(draft.expiresAt),
    },
    VehicleDocumentDraft() => {
      'documentType': draft.type.documentApiName,
      'documentNumber': trimmedOrNull(draft.documentNumber),
      'expiresAt': calendarDateOrNull(draft.expiresAt),
    },
    CnhDraft() => {
      'registrationNumber': draft.registrationNumber.trim(),
      'category': draft.category.trim().toUpperCase(),
      'issueDate': calendarDateOrNull(draft.issueDate),
      'validUntil': calendarDateOrNull(draft.validUntil),
      'issuingState': trimmedOrNull(draft.issuingState)?.toUpperCase(),
    },
  };
}

DocumentDraft draftFromResource(DocumentKind kind, Map<String, Object?> json) {
  return switch (kind) {
    DocumentKind.driverDocument => PersonalDocumentDraft(
      type: readDocumentType(json['documentType']),
      documentNumber: readOptionalText(json['documentNumber']),
      expiresAt: readOptionalCalendarDate(json['expiresAt']),
    ),
    DocumentKind.vehicleDocument => VehicleDocumentDraft(
      vehicleToken: readToken(json['vehicleToken']),
      type: readDocumentType(json['documentType']),
      documentNumber: readOptionalText(json['documentNumber']),
      expiresAt: readOptionalCalendarDate(json['expiresAt']),
    ),
    DocumentKind.driverCnh => CnhDraft(
      registrationNumber: readOptionalText(json['registrationNumber']) ?? '',
      category: readOptionalText(json['category']) ?? '',
      issueDate: readOptionalCalendarDate(json['issueDate']),
      validUntil: readOptionalCalendarDate(json['validUntil']),
      issuingState: readOptionalText(json['issuingState']),
    ),
  };
}

String? trimmedOrNull(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

String? calendarDateOrNull(DateTime? value) =>
    value == null ? null : formatIsoCalendarDate(value);

String? readOptionalText(Object? raw) => raw is String ? raw : null;
