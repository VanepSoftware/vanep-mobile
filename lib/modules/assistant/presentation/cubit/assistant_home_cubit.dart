import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_home_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_today_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/mark_present_in_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/undo_stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';

class AssistantHomeCubit extends Cubit<AssistantHomeState> {
  AssistantHomeCubit({
    required this.findHomeOverview,
    required this.findTodayRoute,
    required this.confirmStopPassengers,
    required this.undoStopConfirmation,
    required this.markPresentInVan,
    required this.respondToInvite,
    this.clock = DateTime.now,
  }) : super(const AssistantHomeState());

  final DateTime Function() clock;

  final RespondToAssistantInvite respondToInvite;

  Future<void> answerInvite(InviteResponse response) async {
    final invite = state.overview?.pendingInvite;
    if (invite == null) return;
    final result = await respondToInvite(invite.token, response);
    if (isClosed) return;
    await result.fold(
      (failure) async =>
          emit(stateWithoutPendingAction().copyWith(actionFailure: failure)),
      (_) => load(),
    );
  }

  final FindAssistantHomeOverview findHomeOverview;
  final FindAssistantTodayRoute findTodayRoute;
  final ConfirmStopPassengers confirmStopPassengers;
  final UndoStopConfirmation undoStopConfirmation;
  final MarkPresentInVan markPresentInVan;

  Future<void> load({String? selectedVanToken}) async {
    emit(const AssistantHomeState());
    final result = await findHomeOverview();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(
        AssistantHomeState(
          status: AssistantHomeLoadStatus.loadFailed,
          failure: failure,
        ),
      ),
      (overview) async {
        final link = selectAssistantVanLink(
          overview.links,
          selectedVanToken ?? requestedVanToken,
          now: clock(),
        );
        final route = await findRouteOf(link);
        if (isClosed) return;
        emit(
          AssistantHomeState(
            status: AssistantHomeLoadStatus.ready,
            overview: overview,
            selectedVanToken: link?.van.token,
            route: route,
          ),
        );
        final requested = requestedVanToken;
        if (requested != null && requested != link?.van.token) {
          await selectVan(requested);
        }
      },
    );
  }

  String? requestedVanToken;

  Future<void> selectVan(String vanToken) async {
    requestedVanToken = vanToken;
    final overview = state.overview;
    if (overview == null || vanToken == state.selectedVanToken) return;
    final link = selectAssistantVanLink(overview.links, vanToken);
    final route = await findRouteOf(link);
    if (isClosed) return;
    emit(
      AssistantHomeState(
        status: AssistantHomeLoadStatus.ready,
        overview: overview,
        selectedVanToken: link?.van.token,
        route: route,
      ),
    );
  }

  Future<AssistantRouteSnapshot?> findRouteOf(AssistantVanLink? link) async {
    if (link == null || !link.isActive) return null;
    final result = await findTodayRoute(link.van.token);
    return result.valueOrNull;
  }

  Future<void> confirmCurrentStop({
    required Set<String> selectedPassengerTokens,
    Map<String, NoShowReason> reasons = const {},
    Map<String, String> notes = const {},
  }) async {
    final route = state.route;
    final stop = route?.currentStop;
    final vanToken = state.selectedVanToken;
    if (route == null || stop == null || vanToken == null) return;
    if (state.isConfirming) return;

    final confirmation = buildStopConfirmation(
      vanToken: vanToken,
      route: route,
      stop: stop,
      selectedPassengerTokens: selectedPassengerTokens,
      reasons: reasons,
      notes: notes,
    );
    final ready = stateWithoutPendingAction();
    emit(ready.copyWith(isConfirming: true));
    final result = await confirmStopPassengers(confirmation);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ready.copyWith(actionFailure: failure),
        (updated) =>
            ready.copyWith(route: updated, lastConfirmation: confirmation),
      ),
    );
  }

  Future<void> correctNoShow(String passengerToken) async {
    final route = state.route;
    final vanToken = state.selectedVanToken;
    if (route == null || vanToken == null || state.isConfirming) return;
    final leg = route.currentLeg ?? TripLeg.outbound;
    final stop = route.boardingStopOf(passengerToken, leg);
    if (stop == null) return;

    final ready = stateWithoutPendingAction();
    emit(ready.copyWith(isConfirming: true));
    final result = await confirmStopPassengers(
      StopConfirmation(
        vanToken: vanToken,
        stopToken: stop.token,
        confirmedPassengerTokens: [passengerToken],
      ),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ready.copyWith(actionFailure: failure),
        (updated) => ready.copyWith(route: updated),
      ),
    );
  }

  Future<void> undoLastConfirmation() async {
    final confirmation = state.lastConfirmation;
    if (confirmation == null) return;
    final result = await undoStopConfirmation(
      vanToken: confirmation.vanToken,
      stopToken: confirmation.stopToken,
    );
    if (isClosed) return;
    final ready = stateWithoutPendingAction();
    emit(
      result.fold(
        (failure) => ready.copyWith(actionFailure: failure),
        (restored) => ready.copyWith(route: restored),
      ),
    );
  }

  Future<void> confirmPresenceInVan() async {
    final vanToken = state.selectedVanToken;
    if (vanToken == null) return;
    final result = await markPresentInVan(vanToken);
    if (isClosed) return;
    final ready = stateWithoutPendingAction();
    emit(
      result.fold(
        (failure) => ready.copyWith(actionFailure: failure),
        (_) => ready.copyWith(isPresentInVan: true),
      ),
    );
  }

  AssistantHomeState stateWithoutPendingAction() => AssistantHomeState(
    status: state.status,
    overview: state.overview,
    selectedVanToken: state.selectedVanToken,
    route: state.route,
    isPresentInVan: state.isPresentInVan,
  );
}
