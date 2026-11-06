import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

abstract class DriverProposalRepository {
  Future<Result<DriverProposalFailure, ProposalComposeDraft>> loadCompose();

  Future<Result<DriverProposalFailure, void>> send(ProposalComposeDraft draft);
}
