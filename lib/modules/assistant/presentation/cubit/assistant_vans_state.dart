import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

enum AssistantVansStatus { loading, ready, loadFailed }

sealed class AssistantVansNotice extends Equatable {
  const AssistantVansNotice();

  @override
  List<Object?> get props => [];
}

class InviteRespondedNotice extends AssistantVansNotice {
  const InviteRespondedNotice(this.response);

  final InviteResponse response;

  @override
  List<Object?> get props => [response];
}

class InviteResponseFailedNotice extends AssistantVansNotice {
  const InviteResponseFailedNotice(this.failure);

  final AssistantFailure failure;

  @override
  List<Object?> get props => [failure];
}

class AssistantVansState extends Equatable {
  const AssistantVansState({
    this.status = AssistantVansStatus.loading,
    this.overview,
    this.failure,
    this.respondingInvite,
    this.notice,
  });

  final AssistantVansStatus status;

  final AssistantVansOverview? overview;

  final AssistantFailure? failure;

  /// The answer being sent for the pending invite, or null when idle.
  final InviteResponse? respondingInvite;

  final AssistantVansNotice? notice;

  AssistantVansState copyWith({
    InviteResponse? respondingInvite,
    bool clearRespondingInvite = false,
    AssistantVansNotice? notice,
  }) {
    return AssistantVansState(
      status: status,
      overview: overview,
      failure: failure,
      respondingInvite: clearRespondingInvite
          ? null
          : respondingInvite ?? this.respondingInvite,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    failure,
    respondingInvite,
    notice,
  ];
}
