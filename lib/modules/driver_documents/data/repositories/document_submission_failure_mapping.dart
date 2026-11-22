import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';

const Map<String, DocumentSubmissionFailure> codeFailures = {
  'document.submission.pending_exists': PendingExistsFailure(),
  'document.submission.reviewed': AlreadyReviewedFailure(),
  'media.file.too_large': FileTooLargeFailure(),
  'media.mime.not_allowed': UnsupportedFileFailure(),
  'media.file.unreadable': UnsupportedFileFailure(),
};

DocumentSubmissionFailure submissionFailureFrom(DioException error) {
  final response = error.response;
  if (response == null) return const NetworkSubmissionFailure();
  return codeFailures[readProblemCode(response.data)] ??
      switch (response.statusCode) {
        413 => const FileTooLargeFailure(),
        400 => const UnsupportedFileFailure(),
        _ => unexpectedFailureFrom(response.data),
      };
}

UnexpectedSubmissionFailure unexpectedFailureFrom(Object? body) {
  final detail = readProblemDetail(body);
  return UnexpectedSubmissionFailure(detail: detail.isEmpty ? null : detail);
}
