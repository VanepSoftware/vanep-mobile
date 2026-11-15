import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/client_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/driver_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/client_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/driver_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/accept_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/request_proposal_adjustment.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';

void registerNegotiationsDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<ClientNegotiationRemoteDataSource>(
      ClientNegotiationRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
      ),
    )
    ..registerSingleton<DriverNegotiationRemoteDataSource>(
      DriverNegotiationRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
      ),
    )
    ..registerSingleton<ClientNegotiationRepository>(
      ClientNegotiationRepositoryImpl(
        remote: getIt<ClientNegotiationRemoteDataSource>(),
      ),
    )
    ..registerSingleton<DriverNegotiationRepository>(
      DriverNegotiationRepositoryImpl(
        remote: getIt<DriverNegotiationRemoteDataSource>(),
      ),
    )
    ..registerFactory<SendServiceRequest>(
      () => SendServiceRequest(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<ListClientServiceRequests>(
      () => ListClientServiceRequests(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<FindClientServiceRequest>(
      () => FindClientServiceRequest(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<WithdrawServiceRequest>(
      () => WithdrawServiceRequest(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<ListClientProposalVersions>(
      () => ListClientProposalVersions(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<FindClientProposal>(
      () => FindClientProposal(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<AcceptProposal>(
      () => AcceptProposal(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<DeclineProposal>(
      () => DeclineProposal(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<RequestProposalAdjustment>(
      () => RequestProposalAdjustment(getIt<ClientNegotiationRepository>()),
    )
    ..registerFactory<ListDriverServiceRequests>(
      () => ListDriverServiceRequests(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<FindDriverServiceRequest>(
      () => FindDriverServiceRequest(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<DeclineServiceRequest>(
      () => DeclineServiceRequest(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<SendProposal>(
      () => SendProposal(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<ListDriverProposalVersions>(
      () => ListDriverProposalVersions(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<FindDriverProposal>(
      () => FindDriverProposal(getIt<DriverNegotiationRepository>()),
    )
    ..registerFactory<WithdrawProposal>(
      () => WithdrawProposal(getIt<DriverNegotiationRepository>()),
    );
}
