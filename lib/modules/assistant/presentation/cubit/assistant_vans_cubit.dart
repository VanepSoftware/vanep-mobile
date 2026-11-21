import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';

class AssistantVansCubit extends Cubit<AssistantVansState> {
  AssistantVansCubit({
    required this.findAssistantVans,
    required this.respondToInvite,
  }) : super(const AssistantVansState());

  final FindAssistantVans findAssistantVans;
  final RespondToAssistantInvite respondToInvite;

  Future<void> loadVans() async {
    emit(const AssistantVansState());
    final result = await findAssistantVans();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantVansState(
          status: AssistantVansStatus.loadFailed,
          failure: failure,
        ),
        (overview) => AssistantVansState(
          status: AssistantVansStatus.ready,
          overview: overview,
        ),
      ),
    );
  }

  Future<void> answerInvite(InviteResponse response) async {
    final invite = state.overview?.pendingInvite;
    if (invite == null) return;
    final result = await respondToInvite(invite.token, response);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(
        AssistantVansState(
          status: AssistantVansStatus.ready,
          overview: state.overview,
          failure: failure,
        ),
      ),
      (_) => loadVans(),
    );
  }
}
