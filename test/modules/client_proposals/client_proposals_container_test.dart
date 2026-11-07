import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/modules/client_proposals/client_proposals_container.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/accept_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/request_proposal_adjustment.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';

import 'client_proposals_mocks.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerFactory<FindMyDependents>(MockFindMyDependents.new)
      ..registerFactory<ListClientServiceRequests>(
        MockListClientServiceRequests.new,
      )
      ..registerFactory<WithdrawServiceRequest>(MockWithdrawServiceRequest.new)
      ..registerFactory<FindClientProposal>(MockFindClientProposal.new)
      ..registerFactory<FindClientServiceRequest>(
        MockFindClientServiceRequest.new,
      )
      ..registerFactory<ListClientProposalVersions>(
        MockListClientProposalVersions.new,
      )
      ..registerFactory<AcceptProposal>(MockAcceptProposal.new)
      ..registerFactory<DeclineProposal>(MockDeclineProposal.new)
      ..registerFactory<RequestProposalAdjustment>(
        MockRequestProposalAdjustment.new,
      )
      ..registerFactory<FindDriverProfile>(MockFindDriverProfile.new)
      ..registerFactory<FindContractReadiness>(MockFindContractReadiness.new)
      ..registerFactory<FindSchoolDays>(MockFindSchoolDays.new)
      ..registerFactory<SendServiceRequest>(MockSendServiceRequest.new);
    registerClientProposalsDependencies(getIt);
  });

  test('resolves the list and its loading', () {
    expect(getIt<LoadClientProposals>(), isA<LoadClientProposals>());
    expect(getIt<ClientProposalsCubit>(), isA<ClientProposalsCubit>());
  });

  test('resolves the detail of a proposal and of a request', () {
    final ofProposal = getIt<ProposalDetailCubit>(
      param1: 'request-1',
      param2: 'proposal-v2',
    );
    final ofRequest = getIt<ProposalDetailCubit>(param1: 'request-1');

    expect(ofProposal.state.proposalToken, 'proposal-v2');
    expect(ofRequest.state.isRequestMode, isTrue);
  });

  test('resolves the adjustment and the decline of a proposal', () {
    expect(
      getIt<ProposalAdjustmentCubit>(param1: 'proposal-v2').proposalToken,
      'proposal-v2',
    );
    expect(
      getIt<ProposalDeclineCubit>(param1: 'proposal-v2').proposalToken,
      'proposal-v2',
    );
  });

  test('resolves the quote request to a driver', () {
    expect(
      getIt<QuoteRequestCubit>(param1: 'driver-carlos').driverToken,
      'driver-carlos',
    );
  });
}
