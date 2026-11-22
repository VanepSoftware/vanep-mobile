import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_student_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';

enum AssistantStudentDetailStatus { loading, ready, loadFailed }

class AssistantStudentDetailState extends Equatable {
  const AssistantStudentDetailState({
    this.status = AssistantStudentDetailStatus.loading,
    this.detail,
    this.failure,
  });

  final AssistantStudentDetailStatus status;
  final AssistantStudentDetail? detail;
  final AssistantFailure? failure;

  @override
  List<Object?> get props => [status, detail, failure];
}

class AssistantStudentDetailCubit extends Cubit<AssistantStudentDetailState> {
  AssistantStudentDetailCubit({required this.findStudentDetail})
    : super(const AssistantStudentDetailState());

  final FindAssistantStudentDetail findStudentDetail;

  Future<void> loadDetail(String studentToken) async {
    emit(const AssistantStudentDetailState());
    final result = await findStudentDetail(studentToken);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantStudentDetailState(
          status: AssistantStudentDetailStatus.loadFailed,
          failure: failure,
        ),
        (detail) => AssistantStudentDetailState(
          status: AssistantStudentDetailStatus.ready,
          detail: detail,
        ),
      ),
    );
  }
}
