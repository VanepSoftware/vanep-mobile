import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/dependent_proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/repositories/client_proposals_repository.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

class ClientProposalsRepositoryImpl implements ClientProposalsRepository {
  const ClientProposalsRepositoryImpl({
    required this.proposalsDataSource,
    required this.childrenDataSource,
  });

  final ProposalsDataSource proposalsDataSource;

  final ProposalChildrenDataSource childrenDataSource;

  @override
  Future<Result<ClientProposalsFailure, ProposalsFeed>> findProposals() async {
    try {
      return Ok(await proposalsDataSource.findProposals());
    } on Object {
      return const Err(ClientProposalsFailure.unexpected);
    }
  }

  @override
  Future<Result<ClientProposalsFailure, List<ProposalChild>>>
  findChildren() async {
    try {
      return Ok(await childrenDataSource.findChildren());
    } on ProposalChildrenUnavailable catch (error) {
      return Err(
        error.isNetwork
            ? ClientProposalsFailure.network
            : ClientProposalsFailure.unexpected,
      );
    } on Object {
      return const Err(ClientProposalsFailure.unexpected);
    }
  }
}
