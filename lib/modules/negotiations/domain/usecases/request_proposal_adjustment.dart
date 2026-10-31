import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';

class RequestProposalAdjustment {
  const RequestProposalAdjustment(this.repository);

  final ClientNegotiationRepository repository;

  Future<Result<NegotiationFailure, Proposal>> call(
    String token,
    ProposalAdjustmentDraft draft,
  ) {
    return repository.requestProposalAdjustment(token, draft);
  }
}
