import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/repositories/driver_proposal_repository.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

class LoadProposalCompose {
  const LoadProposalCompose({required this.repository});

  final DriverProposalRepository repository;

  Future<Result<DriverProposalFailure, ProposalComposeDraft>> call() {
    return repository.loadCompose();
  }
}

DriverProposalFailure? proposalComposeBlockFailure(ProposalComposeBlock block) {
  return switch (block) {
    ProposalComposeBlock.none => null,
    ProposalComposeBlock.overdueInvoice =>
      DriverProposalFailure.overdueInvoice,
    ProposalComposeBlock.notAcceptingStudents =>
      DriverProposalFailure.notAcceptingStudents,
  };
}

class SendDriverProposal {
  const SendDriverProposal({required this.repository});

  final DriverProposalRepository repository;

  Future<Result<DriverProposalFailure, void>> call(
    ProposalComposeDraft draft,
  ) {
    final blocked = proposalComposeBlockFailure(draft.block);
    if (blocked != null) return Future.value(Err(blocked));
    if (!draft.canSend) {
      return Future.value(const Err(DriverProposalFailure.invalidAmount));
    }
    return repository.send(draft);
  }
}
