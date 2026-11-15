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

  int routeRevision = 0;

  void clearRoute() {
    routeRevision++;
    emit(const AssistantChecklistState());
  }

  Future<void> loadRoute(String vanToken) async {
    final revision = ++routeRevision;
    final switchingVan = state.vanToken != vanToken;
    emit(
      state.copyWith(
        isLoading: true,
        isUpdating: false,
        stops: switchingVan ? const [] : state.stops,
        vanToken: () => vanToken,
        selectedStudentTokens: const {},
        isLinkRevoked: false,
        failure: () => null,
      ),
    );

    final result = await getActiveTripRoute(vanToken);
    if (isClosed || revision != routeRevision) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(isLoading: false, stops: value, isLinkRevoked: false),
        );
      case Err(:final error):
        final revoked = isRevocationError(error);
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
    if (!state.allStudents.any(
      (student) =>
          student.studentToken == studentToken &&
          student.status == BoardingStatus.pending,
    )) {
      return;
    }
    if (state.isUpdating || state.isLoading || state.isLinkRevoked) return;
    final revision = routeRevision;
    final currentVanToken = state.vanToken;
    if (currentVanToken == null) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await updateChecklistStatus(
      vanToken: currentVanToken,
      studentTokens: [studentToken],
      status: BoardingStatus.boarded,
      confirmedBy: ConfirmationSource.assistant,
    );

    if (isClosed || revision != routeRevision) return;
    switch (result) {
      case Ok():
        final updatedStops = updateStudentsInStops(
          tokens: {studentToken},
          status: BoardingStatus.boarded,
          confirmedBy: ConfirmationSource.assistant,
          noShowReason: null,
        );
        emit(state.copyWith(isUpdating: false, stops: updatedStops));
      case Err(:final error):
        final revoked = isRevocationError(error);
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
    if (state.isUpdating) return;
    if (!state.allStudents.any(
      (student) =>
          student.studentToken == studentToken &&
          student.status == BoardingStatus.boarded,
    )) {
      return;
    }
    final next = Set<String>.from(state.selectedStudentTokens);
    if (!next.remove(studentToken)) {
      next.add(studentToken);
    }
    emit(state.copyWith(selectedStudentTokens: next));
  }

  void selectAllAtStop(String stopId) {
    if (state.isUpdating) return;
    final stop = state.stops.where((s) => s.id == stopId).firstOrNull;
    if (stop == null) return;

    final eligibleTokens = stop.items
        .where((s) => s.status == BoardingStatus.boarded)
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
    if (state.isUpdating) return;
    emit(state.copyWith(selectedStudentTokens: const {}));
  }

  Future<void> confirmBulkDropOff() async {
    if (state.isUpdating || state.isLoading || state.isLinkRevoked) return;
    final revision = routeRevision;
    final currentVanToken = state.vanToken;
    final tokens = state.allStudents
        .where(
          (student) =>
              student.status == BoardingStatus.boarded &&
              state.selectedStudentTokens.contains(student.studentToken),
        )
        .map((student) => student.studentToken)
        .toList();
    if (currentVanToken == null || tokens.isEmpty) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await updateChecklistStatus(
      vanToken: currentVanToken,
      studentTokens: tokens,
      status: BoardingStatus.droppedOff,
      confirmedBy: ConfirmationSource.assistant,
    );

    if (isClosed || revision != routeRevision) return;
    switch (result) {
      case Ok():
        final updatedStops = updateStudentsInStops(
          tokens: tokens.toSet(),
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
        final revoked = isRevocationError(error);
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
    if (!state.allStudents.any(
      (student) =>
          student.studentToken == studentToken &&
          student.status == BoardingStatus.pending,
    )) {
      return;
    }
    if (state.isUpdating || state.isLoading || state.isLinkRevoked) return;
    final revision = routeRevision;
    final currentVanToken = state.vanToken;
    if (currentVanToken == null) return;

    emit(state.copyWith(isUpdating: true, failure: () => null));

    final result = await recordNoShow(
      vanToken: currentVanToken,
      studentToken: studentToken,
      reason: reason,
    );

    if (isClosed || revision != routeRevision) return;
    switch (result) {
      case Ok():
        final updatedStops = updateStudentsInStops(
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
        final revoked = isRevocationError(error);
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

  bool isRevocationError(AssistantFailure failure) {
    return failure == AssistantFailure.revokedInvite;
  }

  List<AssistantTripStop> updateStudentsInStops({
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
