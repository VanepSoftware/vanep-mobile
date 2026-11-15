import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';

class DeclineServiceRequest {
  const DeclineServiceRequest(this.repository);

  final DriverNegotiationRepository repository;

  Future<Result<NegotiationFailure, DriverServiceRequest>> call(
    String token, {
    String? reason,
  }) {
    return repository.declineServiceRequest(token, reason: reason);
  }
}
