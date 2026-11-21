import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';

const Map<String, DocumentSubmissionFailure> conflictFailures = {
  'document.submission.pending_exists': PendingExistsFailure(),
  'document.submission.reviewed': AlreadyReviewedFailure(),
  'driver_cnh.registration.duplicate': CnhNumberTakenFailure(),
};

const Map<String, FieldRejectedFailure> dateCodeFailures = {
  'document.expires_at.past': FieldRejectedFailure(
    field: DocumentField.expiresAt,
    error: DocumentFieldError.alreadyExpired,
  ),
  'document.expires_at.too_far': FieldRejectedFailure(
    field: DocumentField.expiresAt,
    error: DocumentFieldError.tooFar,
  ),
  'driver_cnh.issue_date.future': FieldRejectedFailure(
    field: DocumentField.cnhIssueDate,
    error: DocumentFieldError.inFuture,
  ),
};

const Map<String, DocumentField> apiFields = {
  'documentNumber': DocumentField.documentNumber,
  'expiresAt': DocumentField.expiresAt,
  'validUntil': DocumentField.expiresAt,
  'registrationNumber': DocumentField.cnhRegistrationNumber,
  'category': DocumentField.cnhCategory,
  'issueDate': DocumentField.cnhIssueDate,
  'issuingState': DocumentField.cnhIssuingState,
};

DocumentSubmissionFailure dataFailureFrom(DioException error) {
  final response = error.response;
  if (response == null) return const NetworkSubmissionFailure();
  final code = readProblemCode(response.data);
  return conflictFailures[code] ??
      dateCodeFailures[code] ??
      fieldFailureFrom(response.statusCode, response.data) ??
      unexpectedFailureFrom(response.data);
}

DocumentSubmissionFailure fileFailureFrom(DioException error) {
  final response = error.response;
  if (response == null) return const NetworkSubmissionFailure();
  final code = readProblemCode(response.data);
  return conflictFailures[code] ??
      switch (response.statusCode) {
        413 => const FileTooLargeFailure(),
        400 => const UnsupportedFileFailure(),
        _ => unexpectedFailureFrom(response.data),
      };
}

FieldRejectedFailure? fieldFailureFrom(int? statusCode, Object? body) {
  if (statusCode != 400) return null;
  final field = apiFields[readProblemField(body)];
  return field == null
      ? null
      : FieldRejectedFailure(
          field: field,
          error: DocumentFieldError.invalidFormat,
        );
}

UnexpectedSubmissionFailure unexpectedFailureFrom(Object? body) {
  final detail = readProblemDetail(body);
  return UnexpectedSubmissionFailure(detail: detail.isEmpty ? null : detail);
}
