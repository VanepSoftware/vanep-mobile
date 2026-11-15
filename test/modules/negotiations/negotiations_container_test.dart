import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
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
import 'package:vanep_mobile/modules/negotiations/negotiations_container.dart';

import 'negotiations_mocks.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(testNegotiationsEnvironment)
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);
    registerNegotiationsDependencies(getIt);
  });

  test('registers one repository per surface', () {
    expect(
      getIt<ClientNegotiationRepository>(),
      isA<ClientNegotiationRepository>(),
    );
    expect(
      getIt<DriverNegotiationRepository>(),
      isA<DriverNegotiationRepository>(),
    );
  });

  test('resolves every use case of the client', () {
    expect(getIt<SendServiceRequest>(), isA<SendServiceRequest>());
    expect(
      getIt<ListClientServiceRequests>(),
      isA<ListClientServiceRequests>(),
    );
    expect(getIt<FindClientServiceRequest>(), isA<FindClientServiceRequest>());
    expect(getIt<WithdrawServiceRequest>(), isA<WithdrawServiceRequest>());
    expect(
      getIt<ListClientProposalVersions>(),
      isA<ListClientProposalVersions>(),
    );
    expect(getIt<FindClientProposal>(), isA<FindClientProposal>());
    expect(getIt<AcceptProposal>(), isA<AcceptProposal>());
    expect(getIt<DeclineProposal>(), isA<DeclineProposal>());
    expect(
      getIt<RequestProposalAdjustment>(),
      isA<RequestProposalAdjustment>(),
    );
  });

  test('resolves every use case of the driver', () {
    expect(
      getIt<ListDriverServiceRequests>(),
      isA<ListDriverServiceRequests>(),
    );
    expect(getIt<FindDriverServiceRequest>(), isA<FindDriverServiceRequest>());
    expect(getIt<DeclineServiceRequest>(), isA<DeclineServiceRequest>());
    expect(getIt<SendProposal>(), isA<SendProposal>());
    expect(
      getIt<ListDriverProposalVersions>(),
      isA<ListDriverProposalVersions>(),
    );
    expect(getIt<FindDriverProposal>(), isA<FindDriverProposal>());
    expect(getIt<WithdrawProposal>(), isA<WithdrawProposal>());
  });
}
