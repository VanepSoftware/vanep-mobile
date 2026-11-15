import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

class SendServiceRequest {
  const SendServiceRequest(this.repository);

  final ClientNegotiationRepository repository;

  Future<Result<NegotiationFailure, ClientServiceRequest>> call(
    ServiceRequestDraft draft,
  ) {
    return repository.sendServiceRequest(draft);
  }
}
