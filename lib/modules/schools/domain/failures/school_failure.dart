import 'package:equatable/equatable.dart';

sealed class SchoolFailure extends Equatable {
  const SchoolFailure();

  @override
  List<Object?> get props => const [];
}

final class SchoolRejectedFailure extends SchoolFailure {
  const SchoolRejectedFailure({required this.detail});

  final String detail;

  @override
  List<Object?> get props => [detail];
}

final class SchoolNetworkFailure extends SchoolFailure {
  const SchoolNetworkFailure();
}

final class SchoolUnexpectedFailure extends SchoolFailure {
  const SchoolUnexpectedFailure();
}
