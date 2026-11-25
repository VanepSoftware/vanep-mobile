import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

DocumentType readRequirementType(Object? raw) =>
    requireRead(DocumentType.fromRequirementApi(raw), 'requirement', raw);

ComplianceState readComplianceState(Object? raw) =>
    requireRead(ComplianceState.fromApi(raw), 'compliance state', raw);

SubmissionStatus readSubmissionStatus(Object? raw) =>
    requireRead(SubmissionStatus.fromApi(raw), 'submission status', raw);

RejectionReason? readOptionalRejectionReason(Object? raw) =>
    RejectionReason.fromApi(raw);

DateTime readCalendarDate(Object? raw) => requireRead(
  parseIsoCalendarDate(raw is String ? raw : null),
  'calendar date',
  raw,
);

DateTime? readOptionalCalendarDate(Object? raw) =>
    raw == null ? null : readCalendarDate(raw);

List<Map<String, Object?>> readKnownRequirements(Object? raw) {
  final entries = raw is List ? raw : const <Object?>[];
  return [
    for (final entry in entries)
      if (entry is Map &&
          DocumentType.fromRequirementApi(entry['requirement']) != null)
        Map<String, Object?>.from(entry),
  ];
}

DocumentFile? readOptionalDocumentFile(Object? raw) {
  if (raw is! Map) return null;
  final mimeType = raw['mimeType'];
  final sizeBytes = raw['sizeBytes'];
  final originalName = raw['originalName'];
  return DocumentFile(
    mimeType: requireRead(
      mimeType is String ? mimeType : null,
      'file type',
      raw,
    ),
    sizeBytes: requireRead(
      sizeBytes is num ? sizeBytes.toInt() : null,
      'file size',
      raw,
    ),
    originalName: originalName is String ? originalName : null,
  );
}
