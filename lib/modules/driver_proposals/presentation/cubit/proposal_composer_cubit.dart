import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_proposal_composer.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_state.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';

DateTime calendarDayOf(DateTime moment) {
  return DateTime(moment.year, moment.month, moment.day);
}

class ProposalComposerCubit extends Cubit<ProposalComposerState> {
  ProposalComposerCubit({
    required this.requestToken,
    required this.loadProposalComposer,
    required this.listMyVans,
    required this.sendProposal,
    this.previousProposalToken,
    DateTime Function() clock = DateTime.now,
  }) : super(ProposalComposerState(today: calendarDayOf(clock())));

  final String requestToken;

  final String? previousProposalToken;

  final LoadProposalComposer loadProposalComposer;

  final ListMyVans listMyVans;

  final SendProposal sendProposal;

  Future<void> load() async {
    emit(
      ProposalComposerState(
        today: state.today,
        status: ProposalComposerStatus.loading,
      ),
    );
    final result = await loadProposalComposer(
      requestToken,
      previousProposalToken: previousProposalToken,
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ProposalComposerState(
          today: state.today,
          status: ProposalComposerStatus.loadFailed,
          failure: failure,
        ),
        (setup) => ProposalComposerState(
          today: state.today,
          status: ProposalComposerStatus.ready,
          setup: setup,
        ),
      ),
    );
  }

  Future<void> refreshVans() async {
    final result = await listMyVans();
    final setup = state.setup;
    if (isClosed || setup == null) return;
    if (result case Ok(value: final vans)) {
      emit(state.copyWith(setup: setup.withVans(vans)));
    }
  }

  void changeDraft(ProposalDraft Function(ProposalDraft draft) change) {
    final setup = state.setup;
    if (setup == null || state.isSending) return;
    emit(state.copyWith(setup: setup.withDraft(change(setup.draft))));
  }

  void changeTotalAmount(int? cents) {
    changeDraft((draft) => draft.withTotalAmount(cents));
  }

  void changeInstallments(int? value) {
    changeDraft((draft) => draft.withInstallments(value));
  }

  void changeDueDay(int? value) =>
      changeDraft((draft) => draft.withDueDay(value));

  void changeStartsOn(DateTime value) {
    changeDraft((draft) => draft.withStartsOn(value));
  }

  void changeEndsOn(DateTime value) {
    changeDraft((draft) => draft.withEndsOn(value));
  }

  void toggleLeg(String dependentToken, RouteLeg leg, Weekday weekday) {
    changeDraft((draft) {
      final item = draft.items.firstWhere(
        (candidate) => candidate.dependentToken == dependentToken,
      );
      return draft.withLeg(
        dependentToken,
        weekday,
        leg,
        enabled: !item.isEnabled(weekday, leg),
      );
    });
  }

  void changeTime(
    String dependentToken,
    Weekday weekday,
    RouteLeg leg,
    ClockTime time,
  ) {
    changeDraft((draft) => draft.withTime(dependentToken, weekday, leg, time));
  }

  void applyTimeToEveryDay(
    String dependentToken,
    RouteLeg leg,
    ClockTime time,
  ) {
    changeDraft((draft) => draft.withTimeOnEveryDay(dependentToken, leg, time));
  }

  void chooseVehicle(String vehicleToken) {
    changeDraft((draft) => draft.withVehicle(vehicleToken));
  }

  void changeEnrollmentFee(int? cents) {
    changeDraft((draft) => draft.withEnrollmentFee(cents));
  }

  void changeAdjustmentPolicy(ProposalAdjustmentPolicy policy) {
    changeDraft((draft) => draft.withAdjustmentPolicy(policy));
  }

  void changeCancellationPolicy(ProposalCancellationPolicy policy) {
    changeDraft((draft) => draft.withCancellationPolicy(policy));
  }

  void changeValidDays(int? value) {
    changeDraft((draft) => draft.withValidDays(value ?? 0));
  }

  void changeMessage(String message) {
    changeDraft((draft) => draft.withMessage(message));
  }

  Future<void> send() async {
    final draft = state.draft;
    if (draft == null || !state.canSend) return;
    emit(state.copyWith(isSending: true));
    final result = await sendProposal(draft);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(failure: failure),
        (proposal) => state.copyWith(sentProposal: proposal),
      ),
    );
  }
}
