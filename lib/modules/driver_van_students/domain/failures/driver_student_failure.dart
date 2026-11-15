import 'package:equatable/equatable.dart';

sealed class DriverStudentFailure extends Equatable {
  const DriverStudentFailure();

  @override
  List<Object?> get props => const [];
}

final class DriverStudentNetworkFailure extends DriverStudentFailure {
  const DriverStudentNetworkFailure();
}

final class DriverStudentNotFoundFailure extends DriverStudentFailure {
  const DriverStudentNotFoundFailure();
}

final class DriverStudentRejectedFailure extends DriverStudentFailure {
  const DriverStudentRejectedFailure({required this.detail});

  final String detail;

  @override
  List<Object?> get props => [detail];
}

final class DriverStudentUnexpectedFailure extends DriverStudentFailure {
  const DriverStudentUnexpectedFailure();
}
