import 'package:equatable/equatable.dart';

sealed class DocumentDisplayState extends Equatable {
  const DocumentDisplayState();

  bool get needsAction;

  @override
  List<Object?> get props => [];
}

final class DocumentNotSent extends DocumentDisplayState {
  const DocumentNotSent({required this.isOptional});

  final bool isOptional;

  @override
  bool get needsAction => true;

  @override
  List<Object?> get props => [isOptional];
}

final class DocumentRejected extends DocumentDisplayState {
  const DocumentRejected();

  @override
  bool get needsAction => true;
}

final class DocumentExpired extends DocumentDisplayState {
  const DocumentExpired();

  @override
  bool get needsAction => true;
}

final class DocumentUnderReview extends DocumentDisplayState {
  const DocumentUnderReview();

  @override
  bool get needsAction => false;
}

final class DocumentRenewalUnderReview extends DocumentDisplayState {
  const DocumentRenewalUnderReview();

  @override
  bool get needsAction => false;
}

final class DocumentExpiringSoon extends DocumentDisplayState {
  const DocumentExpiringSoon({required this.daysLeft});

  final int daysLeft;

  @override
  bool get needsAction => true;

  @override
  List<Object?> get props => [daysLeft];
}

final class DocumentApproved extends DocumentDisplayState {
  const DocumentApproved();

  @override
  bool get needsAction => false;
}
