import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';

// TODO(VAN-42): stands in for the proposals and quote requests endpoint
// (api-java #30), which does not exist yet; replace with a remote data source
// in ClientProposalsContainer once it lands.
class EmptyProposalsDataSource implements ProposalsDataSource {
  const EmptyProposalsDataSource();

  @override
  Future<ProposalsFeed> findProposals() async => const ProposalsFeed();
}
