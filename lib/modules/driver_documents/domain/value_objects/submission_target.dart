import 'package:equatable/equatable.dart';

sealed class SubmissionTarget extends Equatable {
  const SubmissionTarget();

  @override
  List<Object?> get props => [];
}

final class NewSubmission extends SubmissionTarget {
  const NewSubmission();
}

final class ExistingSubmission extends SubmissionTarget {
  const ExistingSubmission(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}
