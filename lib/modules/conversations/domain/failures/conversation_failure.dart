import 'package:equatable/equatable.dart';

sealed class ConversationFailure extends Equatable {
  const ConversationFailure();

  @override
  List<Object?> get props => const [];
}

final class ConversationNetworkFailure extends ConversationFailure {
  const ConversationNetworkFailure();
}

final class ConversationDriverUnavailableFailure extends ConversationFailure {
  const ConversationDriverUnavailableFailure();
}

final class ConversationMessageRejectedFailure extends ConversationFailure {
  const ConversationMessageRejectedFailure();
}

final class ConversationForbiddenFailure extends ConversationFailure {
  const ConversationForbiddenFailure();
}

final class ConversationUnexpectedFailure extends ConversationFailure {
  const ConversationUnexpectedFailure();
}
