import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class ClientProposalsCubit extends Cubit<ClientProposalsState> {
  ClientProposalsCubit({
    required this.loadClientProposals,
    required this.listServiceRequests,
    required this.withdrawServiceRequest,
  }) : super(const ClientProposalsState());

  final LoadClientProposals loadClientProposals;

  final ListClientServiceRequests listServiceRequests;

  final WithdrawServiceRequest withdrawServiceRequest;

  Future<void> loadProposals() async {
    if (state.proposals == null) {
      emit(const ClientProposalsState(status: ClientProposalsStatus.loading));
    }
    final result = await loadClientProposals();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final proposals):
        emit(
          ClientProposalsState(
            status: ClientProposalsStatus.ready,
            proposals: proposals,
            selectedChildToken: proposals
                .childWithToken(state.selectedChildToken)
                ?.token,
            tab: state.tab,
          ),
        );
        await loadAllClosedOfChild();
      case Err(error: final failure) when state.proposals == null:
        emit(
          ClientProposalsState(
            status: ClientProposalsStatus.loadFailed,
            failure: failure,
          ),
        );
      case Err():
        return;
    }
  }

  Future<void> loadMoreClosed() async {
    final proposals = state.proposals;
    if (proposals == null ||
        !proposals.hasMoreClosed ||
        state.isLoadingMoreClosed) {
      return;
    }
    emit(state.copyWith(isLoadingMoreClosed: true));
    final nextPage = proposals.closedPage + 1;
    final result = await listServiceRequests(
      statuses: closedServiceRequestStatuses,
      page: nextPage,
    );
    if (isClosed || !identical(state.proposals, proposals)) return;
    emit(
      result.fold(
        (failure) =>
            state.copyWith(isLoadingMoreClosed: false, actionFailure: failure),
        (page) => state.copyWith(
          proposals: proposals.withClosedPage(page, page: nextPage),
          isLoadingMoreClosed: false,
        ),
      ),
    );
  }

  Future<void> loadAllClosedOfChild() async {
    while (state.selectedChildToken != null &&
        (state.proposals?.hasMoreClosed ?? false) &&
        !state.isLoadingMoreClosed) {
      final proposals = state.proposals;
      await loadMoreClosed();
      if (isClosed || identical(state.proposals, proposals)) return;
    }
  }

  Future<void> cancelRequest(String requestToken) async {
    final proposals = state.proposals;
    if (proposals == null || state.cancellingRequestToken != null) return;
    emit(state.copyWith(cancellingRequestToken: requestToken));
    final result = await withdrawServiceRequest(requestToken);
    if (isClosed) return;
    switch (result) {
      case Ok(value: final withdrawn):
        emit(
          state.copyWith(
            proposals: state.proposals?.withRequestClosed(withdrawn),
            clearCancellingRequest: true,
          ),
        );
        await loadProposals();
      case Err(error: final failure):
        emit(
          state.copyWith(actionFailure: failure, clearCancellingRequest: true),
        );
        if (isNegotiationOutdated(failure)) await loadProposals();
    }
  }

  Future<void> selectChild(String? childToken) async {
    emit(
      state.copyWith(
        selectedChildToken: childToken,
        clearSelectedChild: childToken == null,
      ),
    );
    await loadAllClosedOfChild();
  }

  void selectTab(ProposalsTab tab) {
    emit(state.copyWith(tab: tab));
  }
}
