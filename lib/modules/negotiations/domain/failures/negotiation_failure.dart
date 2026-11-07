import 'package:equatable/equatable.dart';

sealed class NegotiationFailure extends Equatable {
  const NegotiationFailure();

  @override
  List<Object?> get props => const [];
}

final class NegotiationNetworkFailure extends NegotiationFailure {
  const NegotiationNetworkFailure();
}

final class NegotiationNotFoundFailure extends NegotiationFailure {
  const NegotiationNotFoundFailure();
}

final class NegotiationConflictFailure extends NegotiationFailure {
  const NegotiationConflictFailure({required this.detail});

  final String detail;

  @override
  List<Object?> get props => [detail];
}

final class NegotiationRejectedFailure extends NegotiationFailure {
  const NegotiationRejectedFailure({required this.detail});

  final String detail;

  @override
  List<Object?> get props => [detail];
}

final class NegotiationInvalidFailure extends NegotiationFailure {
  const NegotiationInvalidFailure();
}

final class NegotiationUnexpectedFailure extends NegotiationFailure {
  const NegotiationUnexpectedFailure();
}
