import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';

class SendProposal {
  const SendProposal(this.repository);

  final DriverNegotiationRepository repository;

  Future<Result<NegotiationFailure, Proposal>> call(ProposalDraft draft) {
    return repository.sendProposal(draft);
  }
}
