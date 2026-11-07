import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_proposal_detail.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_quote_request.dart';
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

void registerClientProposalsDependencies(GetIt getIt) {
  getIt
    ..registerFactory<LoadClientProposals>(
      () => LoadClientProposals(
        listServiceRequests: getIt<ListClientServiceRequests>(),
        findMyDependents: getIt<FindMyDependents>(),
      ),
    )
    ..registerFactory<LoadProposalDetail>(
      () => LoadProposalDetail(
        findProposal: getIt<FindClientProposal>(),
        findServiceRequest: getIt<FindClientServiceRequest>(),
        listVersions: getIt<ListClientProposalVersions>(),
      ),
    )
    ..registerFactory<LoadQuoteStudents>(
      () => LoadQuoteStudents(
        findMyDependents: getIt<FindMyDependents>(),
        findReadiness: getIt<FindContractReadiness>(),
        findSchoolDays: getIt<FindSchoolDays>(),
      ),
    )
    ..registerFactory<LoadQuoteRequest>(
      () => LoadQuoteRequest(
        findDriverProfile: getIt<FindDriverProfile>(),
        loadQuoteStudents: getIt<LoadQuoteStudents>(),
        listServiceRequests: getIt<ListClientServiceRequests>(),
      ),
    )
    ..registerFactory<ClientProposalsCubit>(
      () => ClientProposalsCubit(
        loadClientProposals: getIt<LoadClientProposals>(),
        listServiceRequests: getIt<ListClientServiceRequests>(),
        withdrawServiceRequest: getIt<WithdrawServiceRequest>(),
      ),
    )
    ..registerFactoryParam<ProposalDetailCubit, String, String?>(
      (requestToken, proposalToken) => ProposalDetailCubit(
        requestToken: requestToken,
        proposalToken: proposalToken,
        loadProposalDetail: getIt<LoadProposalDetail>(),
        acceptProposal: getIt<AcceptProposal>(),
        withdrawServiceRequest: getIt<WithdrawServiceRequest>(),
      ),
    )
    ..registerFactoryParam<ProposalAdjustmentCubit, String, void>(
      (proposalToken, _) => ProposalAdjustmentCubit(
        proposalToken: proposalToken,
        requestAdjustment: getIt<RequestProposalAdjustment>(),
      ),
    )
    ..registerFactoryParam<ProposalDeclineCubit, String, void>(
      (proposalToken, _) => ProposalDeclineCubit(
        proposalToken: proposalToken,
        declineProposal: getIt<DeclineProposal>(),
      ),
    )
    ..registerFactoryParam<QuoteRequestCubit, String, void>(
      (driverToken, _) => QuoteRequestCubit(
        driverToken: driverToken,
        loadQuoteRequest: getIt<LoadQuoteRequest>(),
        loadQuoteStudents: getIt<LoadQuoteStudents>(),
        listServiceRequests: getIt<ListClientServiceRequests>(),
        sendServiceRequest: getIt<SendServiceRequest>(),
      ),
    );
}
