import 'package:equatable/equatable.dart';

sealed class ProfileSummaryFailure extends Equatable {
  const ProfileSummaryFailure();

  @override
  List<Object?> get props => [];
}

class NetworkProfileSummaryFailure extends ProfileSummaryFailure {
  const NetworkProfileSummaryFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnexpectedProfileSummaryFailure extends ProfileSummaryFailure {
  const UnexpectedProfileSummaryFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnsupportedProfileSummaryFailure extends ProfileSummaryFailure {
  const UnsupportedProfileSummaryFailure();
}
