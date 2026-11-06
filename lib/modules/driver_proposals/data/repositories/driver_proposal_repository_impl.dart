import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/datasources/scenario_proposal_compose_datasource.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/repositories/driver_proposal_repository.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

DriverProposalFailure proposalComposeFailureFrom(Object error) {
  if (error is ProposalComposeUnavailable && error.isNetwork) {
    return DriverProposalFailure.network;
  }
  return DriverProposalFailure.unexpected;
}

Future<Result<DriverProposalFailure, T>> guardProposalCompose<T>(
  Future<T> Function() load,
) async {
  try {
    return Ok<DriverProposalFailure, T>(await load());
  } on Object catch (error) {
    return Err<DriverProposalFailure, T>(proposalComposeFailureFrom(error));
  }
}

class DriverProposalRepositoryImpl implements DriverProposalRepository {
  const DriverProposalRepositoryImpl({required this.dataSource});

  final ProposalComposeDataSource dataSource;

  @override
  Future<Result<DriverProposalFailure, ProposalComposeDraft>> loadCompose() {
    return guardProposalCompose(dataSource.loadCompose);
  }

  @override
  Future<Result<DriverProposalFailure, void>> send(
    ProposalComposeDraft draft,
  ) async {
    try {
      await dataSource.send(draft);
      return const Ok<DriverProposalFailure, void>(null);
    } on Object catch (error) {
      return Err<DriverProposalFailure, void>(
        proposalComposeFailureFrom(error),
      );
    }
  }
}
