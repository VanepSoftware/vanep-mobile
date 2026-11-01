import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_decline_reason.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/decline_reason.dart';

class ProposalDeclineCubit extends Cubit<ProposalDeclineState> {
  ProposalDeclineCubit({
    required this.proposalToken,
    required this.declineProposal,
  }) : super(const ProposalDeclineState());

  final String proposalToken;

  final DeclineProposal declineProposal;

  void selectReason(ProposalDeclineReason reason) {
    emit(state.copyWith(reason: reason));
  }

  void changeMessage(String message) {
    emit(state.copyWith(message: message));
  }

  Future<void> send({required String reasonLabel}) async {
    if (!state.canSend || !fitsDeclineReasonLimit(reasonLabel, state.message)) {
      return;
    }
    emit(state.copyWith(isSending: true));
    final result = await declineProposal(
      proposalToken,
      reason: composeDeclineReason(reasonLabel, state.message),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(failure: failure),
        (proposal) => state.copyWith(declinedProposal: proposal),
      ),
    );
  }
}
