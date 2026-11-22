import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';

enum AssistantBoardingHistoryStatus { loading, ready, loadFailed }

class AssistantBoardingHistoryState extends Equatable {
  const AssistantBoardingHistoryState({
    this.status = AssistantBoardingHistoryStatus.loading,
    this.days = const [],
    this.failure,
  });

  final AssistantBoardingHistoryStatus status;
  final List<AssistantBoardingHistoryDay> days;
  final AssistantFailure? failure;

  @override
  List<Object?> get props => [status, days, failure];
}

class AssistantBoardingHistoryCubit
    extends Cubit<AssistantBoardingHistoryState> {
  AssistantBoardingHistoryCubit({
    required this.findBoardingHistory,
    this.clock = DateTime.now,
  }) : super(const AssistantBoardingHistoryState());

  final FindAssistantBoardingHistory findBoardingHistory;
  final DateTime Function() clock;

  Future<void> loadHistory(String studentToken) async {
    emit(const AssistantBoardingHistoryState());
    final result = await findBoardingHistory(studentToken);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantBoardingHistoryState(
          status: AssistantBoardingHistoryStatus.loadFailed,
          failure: failure,
        ),
        (days) => AssistantBoardingHistoryState(
          status: AssistantBoardingHistoryStatus.ready,
          days: latestHistoryFirst(days, now: clock()),
        ),
      ),
    );
  }
}
