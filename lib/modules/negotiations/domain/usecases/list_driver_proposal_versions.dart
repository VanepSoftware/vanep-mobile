import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';

class ListDriverProposalVersions {
  const ListDriverProposalVersions(this.repository);

  final DriverNegotiationRepository repository;

  Future<Result<NegotiationFailure, List<Proposal>>> call(
    String serviceRequestToken,
  ) {
    return repository.listProposalVersions(serviceRequestToken);
  }
}
