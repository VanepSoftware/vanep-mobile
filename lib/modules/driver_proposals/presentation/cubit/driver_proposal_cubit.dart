import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_driver_proposal.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

class DriverProposalCubit extends Cubit<DriverProposalState> {
  DriverProposalCubit({
    required this.requestToken,
    required this.proposalToken,
    required this.loadDriverProposal,
  }) : super(const DriverProposalState());

  final String requestToken;

  final String proposalToken;

  final LoadDriverProposal loadDriverProposal;

  Future<void> load() async {
    if (!state.isReady) {
      emit(const DriverProposalState(status: DriverProposalStatus.loading));
    }
    final result = await loadDriverProposal(
      requestToken,
      proposalToken: proposalToken,
    );
    if (isClosed) return;
    result.fold(
      showLoadFailure,
      (detail) => emit(
        DriverProposalState(status: DriverProposalStatus.ready, detail: detail),
      ),
    );
  }

  void showLoadFailure(NegotiationFailure failure) {
    if (failure is NegotiationNotFoundFailure) {
      emit(const DriverProposalState(status: DriverProposalStatus.notFound));
    } else if (state.isReady) {
      emit(
        DriverProposalState(
          status: state.status,
          detail: state.detail,
          actionFailure: failure,
        ),
      );
    } else {
      emit(const DriverProposalState(status: DriverProposalStatus.loadFailed));
    }
  }
}
