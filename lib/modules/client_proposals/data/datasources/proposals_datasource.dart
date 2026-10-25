import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';

abstract class ProposalsDataSource {
  Future<ProposalsFeed> findProposals();
}
