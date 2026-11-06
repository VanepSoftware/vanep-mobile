import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/proposal_compose_usecases.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

enum ProposalComposeStatus { idle, loading, ready, loadFailed, sending, sent }

class ProposalComposeState extends Equatable {
  const ProposalComposeState({
    this.status = ProposalComposeStatus.idle,
    this.draft,
    this.failure,
  });

  final ProposalComposeStatus status;

  final ProposalComposeDraft? draft;

  final DriverProposalFailure? failure;

  ProposalComposeState withDraft(ProposalComposeDraft draft) {
    return ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: draft,
    );
  }

  ProposalComposeState sending() {
    return ProposalComposeState(
      status: ProposalComposeStatus.sending,
      draft: draft,
    );
  }

  ProposalComposeState sent() {
    return ProposalComposeState(
      status: ProposalComposeStatus.sent,
      draft: draft,
    );
  }

  ProposalComposeState sendFailed(DriverProposalFailure failure) {
    return ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: draft,
      failure: failure,
    );
  }

  ProposalComposeState loadFailed(DriverProposalFailure failure) {
    return ProposalComposeState(
      status: ProposalComposeStatus.loadFailed,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, draft, failure];
}

class ProposalComposeCubit extends Cubit<ProposalComposeState> {
  ProposalComposeCubit({
    required this.loadProposalCompose,
    required this.sendDriverProposal,
  }) : super(const ProposalComposeState());

  final LoadProposalCompose loadProposalCompose;

  final SendDriverProposal sendDriverProposal;

  Future<void> loadDraft() async {
    if (state.draft == null) {
      emit(const ProposalComposeState(status: ProposalComposeStatus.loading));
    }
    final result = await loadProposalCompose();
    result.fold((failure) {
      if (state.draft != null) return;
      emit(state.loadFailed(failure));
    }, (draft) => emit(state.withDraft(draft)));
  }

  void changeStudentPrice(String token, int cents) {
    final draft = state.draft;
    if (draft == null || state.status == ProposalComposeStatus.sending) return;
    if (cents < 0) return;
    final current = draft.students
        .where((student) => student.token == token)
        .firstOrNull;
    if (current == null || current.monthlyAmountCents == cents) return;
    emit(state.withDraft(draft.withStudentAmount(token, cents)));
  }

  Future<void> sendProposal() async {
    final draft = state.draft;
    if (draft == null || !draft.canSend) return;
    if (state.status == ProposalComposeStatus.sending) return;
    emit(state.sending());
    final result = await sendDriverProposal(draft);
    result.fold(
      (failure) => emit(state.sendFailed(failure)),
      (_) => emit(state.sent()),
    );
  }
}
