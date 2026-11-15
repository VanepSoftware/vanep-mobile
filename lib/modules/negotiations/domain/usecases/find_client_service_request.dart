import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';

class FindClientServiceRequest {
  const FindClientServiceRequest(this.repository);

  final ClientNegotiationRepository repository;

  Future<Result<NegotiationFailure, ClientServiceRequest>> call(String token) {
    return repository.findServiceRequest(token);
  }
}
