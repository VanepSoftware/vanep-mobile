import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

abstract class ClientProposalsRepository {
  Future<Result<ClientProposalsFailure, ProposalsFeed>> findProposals();

  Future<Result<ClientProposalsFailure, List<ProposalChild>>> findChildren();
}
