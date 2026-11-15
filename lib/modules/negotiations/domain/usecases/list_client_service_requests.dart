import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class ListClientServiceRequests {
  const ListClientServiceRequests(this.repository);

  final ClientNegotiationRepository repository;

  Future<Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>>>
  call({
    required Set<ServiceRequestStatus> statuses,
    String? conversationToken,
    int page = 0,
  }) {
    return repository.listMyServiceRequests(
      statuses: statuses,
      conversationToken: conversationToken,
      page: page,
    );
  }
}
