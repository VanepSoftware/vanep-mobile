import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';

const int bytesInMegabyte = 1024 * 1024;

String captureFailureMessage(
  AppLocalizations l10n,
  DocumentCaptureFailure failure,
) {
  return switch (failure) {
    DocumentCaptureFailure.permissionDenied =>
      l10n.documentCapturePermissionDenied,
    DocumentCaptureFailure.tooLarge => l10n.documentFileTooLarge,
    DocumentCaptureFailure.unexpected => l10n.documentCaptureFailed,
  };
}

String? submissionFailureMessage(
  AppLocalizations l10n,
  DocumentSubmissionFailure failure,
) {
  return switch (failure) {
    PendingExistsFailure() => l10n.documentSubmissionPendingExists,
    AlreadyReviewedFailure() => l10n.documentSubmissionAlreadyReviewed,
    UnsupportedFileFailure() => l10n.documentSubmissionUnsupportedFile,
    FileTooLargeFailure() => l10n.documentFileTooLarge,
    UnexpectedSubmissionFailure(:final detail) =>
      detail ?? l10n.documentSubmissionUnexpected,
    NetworkSubmissionFailure() => null,
  };
}

String formatMegabytes(AppLocalizations l10n, int bytes) {
  return NumberFormat('0.0', l10n.localeName).format(bytes / bytesInMegabyte);
}

int progressPercent(int sentBytes, int totalBytes) {
  if (totalBytes <= 0) return 0;
  return (sentBytes * 100 / totalBytes).floor().clamp(0, 100);
}
