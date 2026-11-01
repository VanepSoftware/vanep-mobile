import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/request_proposal_adjustment.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';

class ProposalAdjustmentCubit extends Cubit<ProposalAdjustmentState> {
  ProposalAdjustmentCubit({
    required this.proposalToken,
    required this.requestAdjustment,
  }) : super(const ProposalAdjustmentState());

  final String proposalToken;

  final RequestProposalAdjustment requestAdjustment;

  void selectField(ProposalAdjustmentField field) {
    if (state.draft.field == field) return;
    emit(
      state.copyWith(
        draft: ProposalAdjustmentDraft(field: field, note: state.draft.note),
      ),
    );
  }

  void changeSuggestedValue(String value) {
    emit(state.copyWith(draft: state.draft.withSuggestedValue(value)));
  }

  void changeNote(String value) {
    emit(state.copyWith(draft: state.draft.withNote(value)));
  }

  Future<void> send() async {
    if (!state.canSend) return;
    emit(state.copyWith(isSending: true));
    final result = await requestAdjustment(proposalToken, state.draft);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(failure: failure),
        (proposal) => state.copyWith(sentProposal: proposal),
      ),
    );
  }
}
