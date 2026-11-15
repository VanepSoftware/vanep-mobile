import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_proposal_detail.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/accept_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';

class ProposalDetailCubit extends Cubit<ProposalDetailState> {
  ProposalDetailCubit({
    required this.requestToken,
    required this.loadProposalDetail,
    required this.acceptProposal,
    required this.withdrawServiceRequest,
    String? proposalToken,
  }) : super(ProposalDetailState(proposalToken: proposalToken));

  final String requestToken;

  final LoadProposalDetail loadProposalDetail;

  final AcceptProposal acceptProposal;

  final WithdrawServiceRequest withdrawServiceRequest;

  Future<void> load() async {
    if (!state.isReady) {
      emit(
        ProposalDetailState(
          status: ProposalDetailStatus.loading,
          proposalToken: state.proposalToken,
        ),
      );
    }
    final proposalToken = state.proposalToken;
    final result = await loadProposalDetail(
      requestToken,
      proposalToken: proposalToken,
    );
    if (isClosed) return;
    result.fold(
      showLoadFailure,
      (detail) => emit(
        ProposalDetailState(
          status: ProposalDetailStatus.ready,
          proposalToken: proposalToken,
          request: detail.request,
          proposal: detail.proposal,
          versions: detail.versions,
        ),
      ),
    );
  }

  void showLoadFailure(NegotiationFailure failure) {
    if (failure is NegotiationNotFoundFailure) {
      emit(
        ProposalDetailState(
          status: ProposalDetailStatus.notFound,
          proposalToken: state.proposalToken,
        ),
      );
      return;
    }
    if (state.isReady) {
      emit(state.copyWith(actionFailure: failure));
      return;
    }
    emit(
      ProposalDetailState(
        status: ProposalDetailStatus.loadFailed,
        proposalToken: state.proposalToken,
        loadFailure: failure,
      ),
    );
  }

  Future<void> showVersion(String proposalToken) async {
    emit(state.copyWith(proposalToken: proposalToken));
    await load();
  }

  Future<void> loadAndAccept() async {
    await load();
    if (state.canAct) await accept();
  }

  Future<void> accept() async {
    final proposal = state.proposal;
    if (proposal == null || !state.canAct || state.isAccepting) return;
    emit(state.copyWith(isAccepting: true));
    final result = await acceptProposal(proposal.token);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        showAccepted(value);
      case Err(error: NegotiationNotFoundFailure()):
        emit(state.copyWith(status: ProposalDetailStatus.notFound));
      case Err(:final error):
        emit(state.copyWith(actionFailure: error));
        if (isNegotiationOutdated(error)) await load();
    }
  }

  void showAccepted(Proposal accepted) {
    emit(state.copyWith(proposal: accepted, acceptedProposal: accepted));
  }

  Future<void> cancelRequest() async {
    if (!state.isReady || state.isCancelling) return;
    emit(state.copyWith(isCancelling: true));
    final result = await withdrawServiceRequest(requestToken);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(request: value, cancelledRequest: value));
      case Err(:final error):
        emit(state.copyWith(actionFailure: error));
        if (isNegotiationOutdated(error)) await load();
    }
  }
}
