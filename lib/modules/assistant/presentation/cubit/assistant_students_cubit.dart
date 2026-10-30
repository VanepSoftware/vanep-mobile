import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_students.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_state.dart';

class AssistantStudentsCubit extends Cubit<AssistantStudentsState> {
  AssistantStudentsCubit({required this.findAssistantStudents})
    : super(const AssistantStudentsState());

  final FindAssistantStudents findAssistantStudents;

  Future<void> loadStudents() async {
    emit(const AssistantStudentsState());
    final result = await findAssistantStudents();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantStudentsState(
          status: AssistantStudentsStatus.loadFailed,
          failure: failure,
        ),
        (overview) => AssistantStudentsState(
          status: AssistantStudentsStatus.ready,
          overview: overview,
        ),
      ),
    );
  }

  void selectRoster(int index) {
    emit(state.copyWith(selectedRosterIndex: index, query: ''));
  }

  void search(String query) {
    emit(state.copyWith(query: query));
  }
}
