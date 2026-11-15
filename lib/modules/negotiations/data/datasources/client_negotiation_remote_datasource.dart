import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/negotiation_payloads.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_request_body.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/proposal_dto.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/service_request_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class ClientNegotiationRemoteDataSource {
  const ClientNegotiationRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  String get requestsEndpoint => environment.clientServiceRequestsEndpoint;

  String get proposalsEndpoint => environment.clientProposalsEndpoint;

  Future<ClientServiceRequest> sendServiceRequest(
    ServiceRequestDraft draft,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      requestsEndpoint,
      data: serviceRequestDraftToJson(draft),
    );
    return readOne(response.data, ClientServiceRequestDto.fromJson);
  }

  Future<NegotiationPage<ClientServiceRequest>> listMyServiceRequests({
    required Set<ServiceRequestStatus> statuses,
    String? conversationToken,
    int page = 0,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      requestsEndpoint,
      queryParameters: listQuery(
        statuses: statuses,
        conversationToken: conversationToken,
        page: page,
      ),
    );
    return readPage(response.data, ClientServiceRequestDto.fromJson);
  }

  Future<ClientServiceRequest> findServiceRequest(String token) async {
    final response = await dio.get<Map<String, dynamic>>(
      negotiationPath(requestsEndpoint, token),
    );
    return readOne(response.data, ClientServiceRequestDto.fromJson);
  }

  Future<ClientServiceRequest> withdrawServiceRequest(String token) async {
    final response = await dio.post<Map<String, dynamic>>(
      negotiationPath(requestsEndpoint, token, 'withdraw'),
    );
    return readOne(response.data, ClientServiceRequestDto.fromJson);
  }

  Future<List<Proposal>> listProposalVersions(
    String serviceRequestToken,
  ) async {
    final response = await dio.get<List<dynamic>>(
      negotiationPath(requestsEndpoint, serviceRequestToken, 'proposals'),
    );
    return readProposalVersions(response.data);
  }

  Future<Proposal> findProposal(String token) async {
    final response = await dio.get<Map<String, dynamic>>(
      negotiationPath(proposalsEndpoint, token),
    );
    return readOne(response.data, ProposalDto.fromJson);
  }

  Future<Proposal> acceptProposal(String token) async {
    final response = await dio.post<Map<String, dynamic>>(
      negotiationPath(proposalsEndpoint, token, 'accept'),
    );
    return readOne(response.data, ProposalDto.fromJson);
  }

  Future<Proposal> declineProposal(String token, {String? reason}) async {
    final response = await dio.post<Map<String, dynamic>>(
      negotiationPath(proposalsEndpoint, token, 'decline'),
      data: declineToJson(reason),
    );
    return readOne(response.data, ProposalDto.fromJson);
  }

  Future<Proposal> requestProposalAdjustment(
    String token,
    ProposalAdjustmentDraft draft,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      negotiationPath(proposalsEndpoint, token, 'adjustments'),
      data: proposalAdjustmentDraftToJson(draft),
    );
    return readOne(response.data, ProposalDto.fromJson);
  }
}
