import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_active_trip_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/record_no_show.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/update_checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';

class AssistantChecklistCubit extends Cubit<AssistantChecklistState> {
  AssistantChecklistCubit({
    required this.getActiveTripRoute,
    required this.updateChecklistStatus,
    required this.recordNoShow,
  }) : super(const AssistantChecklistState());

  final GetActiveTripRoute getActiveTripRoute;

  final UpdateChecklistStatus updateChecklistStatus;

  final RecordNoShow recordNoShow;

  Future<void> loadRoute(String vanToken) async {
    emit(
      state.copyWith(
        isLoading: true,
        vanToken: () => vanToken,
        selectedStudentTokens: const {},
        isLinkRevoked: false,
        failure: () => null,
      ),
    );

    final result = await getActiveTripRoute(vanToken);
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            stops: value,
            isLinkRevoked: false,
          ),
        );
      case Err(:final error):
        final revoked = _isRevocationError(error);
        emit(
          state.copyWith(
            isLoading: false,
            stops: revoked ? const [] : state.stops,
            isLinkRevoked: revoked,
            failure: () => error,
          ),
        );
    }
  }

  Future<void> confirmBoarding(String studentToken) async {
    final currentVanToken = state.vanToken;
    if (currentVanToken == null) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await updateChecklistStatus(
      vanToken: currentVanToken,
      studentTokens: [studentToken],
      status: BoardingStatus.boarded,
      confirmedBy: ConfirmationSource.assistant,
    );

    switch (result) {
      case Ok():
        final updatedStops = _updateStudentsInStops(
          tokens: {studentToken},
          status: BoardingStatus.boarded,
          confirmedBy: ConfirmationSource.assistant,
          noShowReason: null,
        );
        emit(
          state.copyWith(
            isUpdating: false,
            stops: updatedStops,
          ),
        );
      case Err(:final error):
        final revoked = _isRevocationError(error);
        emit(
          state.copyWith(
            isUpdating: false,
            isLinkRevoked: revoked,
            failure: () => error,
          ),
        );
    }
  }

  void toggleStudentSelection(String studentToken) {
    final next = Set<String>.from(state.selectedStudentTokens);
    if (!next.remove(studentToken)) {
      next.add(studentToken);
    }
    emit(state.copyWith(selectedStudentTokens: next));
  }

  void selectAllAtStop(String stopId) {
    final stop = state.stops.where((s) => s.id == stopId).firstOrNull;
    if (stop == null) return;

    final eligibleTokens = stop.items
        .where(
          (s) =>
              s.status == BoardingStatus.boarded ||
              s.status == BoardingStatus.pending,
        )
        .map((s) => s.studentToken)
        .toSet();

    final next = Set<String>.from(state.selectedStudentTokens);
    final allAlreadySelected =
        eligibleTokens.isNotEmpty && eligibleTokens.every(next.contains);

    if (allAlreadySelected) {
      next.removeAll(eligibleTokens);
    } else {
      next.addAll(eligibleTokens);
    }
    emit(state.copyWith(selectedStudentTokens: next));
  }

  void clearSelection() {
    emit(state.copyWith(selectedStudentTokens: const {}));
  }

  Future<void> confirmBulkDropOff() async {
    final currentVanToken = state.vanToken;
    final tokens = state.selectedStudentTokens.toList();
    if (currentVanToken == null || tokens.isEmpty) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await updateChecklistStatus(
      vanToken: currentVanToken,
      studentTokens: tokens,
      status: BoardingStatus.droppedOff,
      confirmedBy: ConfirmationSource.assistant,
    );

    switch (result) {
      case Ok():
        final updatedStops = _updateStudentsInStops(
          tokens: state.selectedStudentTokens,
          status: BoardingStatus.droppedOff,
          confirmedBy: ConfirmationSource.assistant,
          noShowReason: null,
        );
        emit(
          state.copyWith(
            isUpdating: false,
            stops: updatedStops,
            selectedStudentTokens: const {},
          ),
        );
      case Err(:final error):
        final revoked = _isRevocationError(error);
        emit(
          state.copyWith(
            isUpdating: false,
            isLinkRevoked: revoked,
            failure: () => error,
          ),
        );
    }
  }

  Future<void> markNoShow(String studentToken, NoShowReason reason) async {
    final currentVanToken = state.vanToken;
    if (currentVanToken == null) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await recordNoShow(
      vanToken: currentVanToken,
      studentToken: studentToken,
      reason: reason,
    );

    switch (result) {
      case Ok():
        final updatedStops = _updateStudentsInStops(
          tokens: {studentToken},
          status: BoardingStatus.noShow,
          confirmedBy: ConfirmationSource.assistant,
          noShowReason: reason,
        );
        final nextSelection = Set<String>.from(state.selectedStudentTokens)
          ..remove(studentToken);
        emit(
          state.copyWith(
            isUpdating: false,
            stops: updatedStops,
            selectedStudentTokens: nextSelection,
          ),
        );
      case Err(:final error):
        final revoked = _isRevocationError(error);
        emit(
          state.copyWith(
            isUpdating: false,
            isLinkRevoked: revoked,
            failure: () => error,
          ),
        );
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateStatusFilter(BoardingStatus? status) {
    emit(state.copyWith(statusFilter: () => status));
  }

  bool _isRevocationError(AssistantFailure failure) {
    return failure == AssistantFailure.revokedInvite ||
        failure == AssistantFailure.unauthorized;
  }

  List<AssistantTripStop> _updateStudentsInStops({
    required Set<String> tokens,
    required BoardingStatus status,
    required ConfirmationSource confirmedBy,
    required NoShowReason? noShowReason,
  }) {
    return state.stops.map((stop) {
      final updatedItems = stop.items.map((student) {
        if (!tokens.contains(student.studentToken)) {
          return student;
        }
        return student.copyWith(
          status: status,
          confirmedBy: () => confirmedBy,
          noShowReason: () => noShowReason,
        );
      }).toList();

      return stop.copyWith(items: updatedItems);
    }).toList();
  }
}
