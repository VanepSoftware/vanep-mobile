import 'package:equatable/equatable.dart';

import '../value_objects/dependent_draft.dart';

sealed class DependentFailure extends Equatable {
  const DependentFailure();

  @override
  List<Object?> get props => const [];
}

final class DependentValidationFailure extends DependentFailure {
  const DependentValidationFailure({this.messagesByField = const {}});

  final Map<DependentField, String> messagesByField;

  bool get isAttributedToAField => messagesByField.isNotEmpty;

  @override
  List<Object?> get props => [messagesByField];
}

final class DependentNotFoundFailure extends DependentFailure {
  const DependentNotFoundFailure();
}

final class DependentCityNotFoundFailure extends DependentFailure {
  const DependentCityNotFoundFailure();
}

final class DependentNetworkFailure extends DependentFailure {
  const DependentNetworkFailure();
}

final class DependentUnexpectedFailure extends DependentFailure {
  const DependentUnexpectedFailure();
}
