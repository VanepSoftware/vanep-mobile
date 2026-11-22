import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_van_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/leave_assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';

enum AssistantVanDetailStatus { loading, ready, loadFailed, left }

class AssistantVanDetailState extends Equatable {
  const AssistantVanDetailState({
    this.status = AssistantVanDetailStatus.loading,
    this.detail,
    this.failure,
    this.isLeaving = false,
  });

  final AssistantVanDetailStatus status;
  final AssistantVanDetail? detail;
  final AssistantFailure? failure;
  final bool isLeaving;

  @override
  List<Object?> get props => [status, detail, failure, isLeaving];
}

class AssistantVanDetailCubit extends Cubit<AssistantVanDetailState> {
  AssistantVanDetailCubit({
    required this.findVanDetail,
    required this.leaveAssistantVan,
  }) : super(const AssistantVanDetailState());

  final FindAssistantVanDetail findVanDetail;
  final LeaveAssistantVan leaveAssistantVan;

  Future<void> loadDetail(String vanToken) async {
    emit(const AssistantVanDetailState());
    final result = await findVanDetail(vanToken);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantVanDetailState(
          status: AssistantVanDetailStatus.loadFailed,
          failure: failure,
        ),
        (detail) => AssistantVanDetailState(
          status: AssistantVanDetailStatus.ready,
          detail: detail,
        ),
      ),
    );
  }

  Future<void> leaveVan() async {
    final detail = state.detail;
    if (detail == null || state.isLeaving) return;
    emit(
      AssistantVanDetailState(
        status: AssistantVanDetailStatus.ready,
        detail: detail,
        isLeaving: true,
      ),
    );
    final result = await leaveAssistantVan(detail.van.token);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantVanDetailState(
          status: AssistantVanDetailStatus.ready,
          detail: detail,
          failure: failure,
        ),
        (_) => AssistantVanDetailState(
          status: AssistantVanDetailStatus.left,
          detail: detail,
        ),
      ),
    );
  }
}
