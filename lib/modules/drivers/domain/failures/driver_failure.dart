import 'package:equatable/equatable.dart';

sealed class DriverFailure extends Equatable {
  const DriverFailure();

  @override
  List<Object?> get props => [];
}

class NetworkDriverFailure extends DriverFailure {
  const NetworkDriverFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnexpectedDriverFailure extends DriverFailure {
  const UnexpectedDriverFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
