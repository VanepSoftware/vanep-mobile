import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';

class ClientProposalsCubit extends Cubit<ClientProposalsState> {
  ClientProposalsCubit({required this.loadClientProposals})
    : super(const ClientProposalsState());

  final LoadClientProposals loadClientProposals;

  Future<void> loadProposals() async {
    if (state.proposals == null) {
      emit(const ClientProposalsState(status: ClientProposalsStatus.loading));
    }
    final result = await loadClientProposals();
    result.fold(
      (failure) {
        if (state.proposals != null) return;
        emit(
          ClientProposalsState(
            status: ClientProposalsStatus.loadFailed,
            failure: failure,
          ),
        );
      },
      (proposals) => emit(
        ClientProposalsState(
          status: ClientProposalsStatus.ready,
          proposals: proposals,
          selectedChildToken: proposals
              .childWithToken(state.selectedChildToken)
              ?.token,
          tab: state.tab,
        ),
      ),
    );
  }

  void selectChild(String? childToken) {
    emit(state.withSelectedChild(childToken));
  }

  void selectTab(ProposalsTab tab) {
    emit(state.withTab(tab));
  }
}
