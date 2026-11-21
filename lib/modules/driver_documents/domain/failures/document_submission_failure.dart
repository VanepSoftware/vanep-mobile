import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';

sealed class DocumentSubmissionFailure extends Equatable {
  const DocumentSubmissionFailure();

  @override
  List<Object?> get props => [];
}

final class PendingExistsFailure extends DocumentSubmissionFailure {
  const PendingExistsFailure();
}

final class AlreadyReviewedFailure extends DocumentSubmissionFailure {
  const AlreadyReviewedFailure();
}

final class CnhNumberTakenFailure extends DocumentSubmissionFailure {
  const CnhNumberTakenFailure();
}

final class FieldRejectedFailure extends DocumentSubmissionFailure {
  const FieldRejectedFailure({required this.field, required this.error});

  final DocumentField field;
  final DocumentFieldError error;

  @override
  List<Object?> get props => [field, error];
}

final class UnsupportedFileFailure extends DocumentSubmissionFailure {
  const UnsupportedFileFailure();
}

final class FileTooLargeFailure extends DocumentSubmissionFailure {
  const FileTooLargeFailure();
}

final class NetworkSubmissionFailure extends DocumentSubmissionFailure {
  const NetworkSubmissionFailure();
}

final class UnexpectedSubmissionFailure extends DocumentSubmissionFailure {
  const UnexpectedSubmissionFailure({this.detail});

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
