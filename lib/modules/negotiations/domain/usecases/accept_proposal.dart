import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';

class AcceptProposal {
  const AcceptProposal(this.repository);

  final ClientNegotiationRepository repository;

  Future<Result<NegotiationFailure, Proposal>> call(String token) {
    return repository.acceptProposal(token);
  }
}
