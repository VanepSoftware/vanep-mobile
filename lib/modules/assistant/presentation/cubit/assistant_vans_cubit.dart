import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';

class AssistantVansCubit extends Cubit<AssistantVansState> {
  AssistantVansCubit({
    required this.findAssistantVans,
    required this.respondToAssistantInvite,
  }) : super(const AssistantVansState());

  final FindAssistantVans findAssistantVans;
  final RespondToAssistantInvite respondToAssistantInvite;

  Future<void> loadVans() async {
    emit(const AssistantVansState());
    await _fetch();
  }

  Future<void> respondToInvite(InviteResponse response) async {
    final invite = state.overview?.pendingInvite;
    if (invite == null || state.respondingInvite != null) return;

    emit(state.copyWith(respondingInvite: response));
    final result = await respondToAssistantInvite(invite.token, response);
    if (isClosed) return;

    final failure = result.errorOrNull;
    if (failure != null) {
      emit(
        state.copyWith(
          clearRespondingInvite: true,
          notice: InviteResponseFailedNotice(failure),
        ),
      );
      return;
    }
    await _fetch(notice: InviteRespondedNotice(response));
  }

  void clearNotice() {
    if (state.notice == null) return;
    emit(state.copyWith());
  }

  Future<void> _fetch({AssistantVansNotice? notice}) async {
    final result = await findAssistantVans();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantVansState(
          status: AssistantVansStatus.loadFailed,
          failure: failure,
          notice: notice,
        ),
        (overview) => AssistantVansState(
          status: AssistantVansStatus.ready,
          overview: overview,
          notice: notice,
        ),
      ),
    );
  }
}
