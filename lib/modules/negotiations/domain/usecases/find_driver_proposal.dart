import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';

class FindDriverProposal {
  const FindDriverProposal(this.repository);

  final DriverNegotiationRepository repository;

  Future<Result<NegotiationFailure, Proposal>> call(String token) {
    return repository.findProposal(token);
  }
}
