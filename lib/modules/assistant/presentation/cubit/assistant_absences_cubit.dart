import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_absences.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_absences_state.dart';

class AssistantAbsencesCubit extends Cubit<AssistantAbsencesState> {
  AssistantAbsencesCubit({
    required this.findAssistantAbsences,
    this.clock = DateTime.now,
  }) : super(const AssistantAbsencesState());

  final FindAssistantAbsences findAssistantAbsences;
  final DateTime Function() clock;

  Future<void> loadAbsences(String vanToken) async {
    emit(const AssistantAbsencesState());
    final result = await findAssistantAbsences(vanToken);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantAbsencesState(
          status: AssistantAbsencesStatus.loadFailed,
          failure: failure,
        ),
        (absences) => AssistantAbsencesState(
          status: AssistantAbsencesStatus.ready,
          overview: groupAssistantAbsences(absences, now: clock()),
        ),
      ),
    );
  }
}
