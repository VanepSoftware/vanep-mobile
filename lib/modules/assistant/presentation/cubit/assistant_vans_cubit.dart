import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';

class AssistantVansCubit extends Cubit<AssistantVansState> {
  AssistantVansCubit({required this.findAssistantVans})
    : super(const AssistantVansState());

  final FindAssistantVans findAssistantVans;

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
}
