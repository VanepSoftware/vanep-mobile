import 'package:equatable/equatable.dart';

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
