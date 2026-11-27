import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';

const Map<String, DocumentSubmissionFailure> codeFailures = {
  ApiErrorCodes.documentSubmissionPendingExists: PendingExistsFailure(),
  ApiErrorCodes.documentSubmissionReviewed: AlreadyReviewedFailure(),
  ApiErrorCodes.mediaFileTooLarge: FileTooLargeFailure(),
  ApiErrorCodes.requestPayloadTooLarge: FileTooLargeFailure(),
  ApiErrorCodes.mediaMimeNotAllowed: UnsupportedFileFailure(),
  ApiErrorCodes.mediaFileUnreadable: UnsupportedFileFailure(),
  ApiErrorCodes.mediaFileRequired: UnsupportedFileFailure(),
};

DocumentSubmissionFailure submissionFailureFrom(DioException error) {
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) return const NetworkSubmissionFailure();
  return codeFailures[problem.code] ??
      switch (problem.status) {
        413 => const FileTooLargeFailure(),
        400 => const UnsupportedFileFailure(),
        _ => unexpectedFailureFrom(problem),
      };
}

UnexpectedSubmissionFailure unexpectedFailureFrom(ApiProblem problem) {
  final detail = problem.detailText;
  return UnexpectedSubmissionFailure(detail: detail.isEmpty ? null : detail);
}
